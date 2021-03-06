#!/bin/bash

RESTIC_REPOSITORY=${RESTIC_REPOSITORY:-""}
RESTIC_PASSWORD=${RESTIC_PASSWORD:-""}
DATA_DIRECTORY=${DATA_DIRECTORY:-""}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}

RESTIC_ARGS=${1:-""}

PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-""}"

MAX_AGE="${MAX_AGE:-"691200"}"

# Configurable labels
INSTANCE="${INSTANCE:-""}"
NAMESPACE="${NAMESPACE:-""}"
TIER="${TIER:-""}"

TIMEOUT="${TIMEOUT:-"60m"}"

# set -Eeuo pipefail
set -o pipefail

trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
	if [ "$?" -eq 124 ]; then
		echo "ERROR: one of restic commands timed out. Try changing TIMEOUT env to higher value."
	fi
	restic unlock --remove-all -v || echo "Couldn't unlock repository"
}

unlock() {
	timeout "${TIMEOUT}" restic unlock --remove-all || exit 124
}

check() {
	echo "INFO: checking repository state"
	if ! timeout "$TIMEOUT" restic check; then
		echo "ERROR: check operation took too long and was aborted. Continuing anyway."
		unlock
		return 1
	fi
}

# TODO: Use json data to create metrics
forget() {
	echo "INFO: forgettting old snapshots"
	# Do not run with `--prune` as it can take a long time and get into timeout boundry
	if ! timeout "$TIMEOUT" restic forget --json --keep-last 14 --keep-daily 7 --keep-monthly 6 --keep-yearly 2; then
		echo "ERROR: forget operation took too long and was aborted. Continuing anyway."
		unlock
		return 1
	fi
}

prune() {
	echo "INFO: pruning old data"
	if ! timeout "$TIMEOUT" restic prune --json; then
		echo "ERROR: pruning took too long and was aborted. Continuing anyway."
		unlock
		return 1
	fi
}


backup() {
	local data stats snapshots metrics_url
	local check_failed=0
	local forget_failed=0
	local prune_failed=0

	# Initialize variables
	if [ -n "$DATA_DIRECTORY" ]; then
		data="${DATA_DIRECTORY}"
	elif [ -n "${MYSQL_DATABASE}" ]; then
		data="${MYSQL_DATABASE}_dump.sql"
	fi
	metrics_url="${PUSHGATEWAY_URL}/metrics/job/backup"
	if [ "${NAMESPACE}" != "" ]; then
		metrics_url="${metrics_url}/namespace@base64/$(echo -n "${NAMESPACE}" | base64 )"
	fi
	if [ "${INSTANCE}" != "" ]; then
		metrics_url="${metrics_url}/instance@base64/$(echo -n "${INSTANCE}" | base64)"
	fi
	if [ "${TIER}" != "" ]; then
		metrics_url="${metrics_url}/tier@base64/$(echo -n "${TIER}" | base64)"
	fi
	metrics_url="${metrics_url}/repository@base64/$(echo -n "${RESTIC_REPOSITORY}" | base64 )"
	metrics_url="${metrics_url}/data@base64/$(echo -n "${data}" | base64 )"

	# Send startup metrics
	if [ -n "$PUSHGATEWAY_URL" ]; then
		cat <<EOF | curl -iv --data-binary @- "${metrics_url}" 2> /dev/null
# HELP job_start_timestamp_seconds Time when job started
# TYPE job_start_timestamp_seconds gauge
job_start_timestamp_seconds $(date +%s)
# HELP job_max_age_seconds The SLO value for alerting, in seconds
# TYPE job_max_age_seconds gauge
job_max_age_seconds ${MAX_AGE}
# HELP job_success_timestamp_seconds Time when job started
# TYPE job_success_timestamp_seconds gauge
job_success_timestamp_seconds 0
EOF

	fi

	echo "INFO: Releasing all locks"
	if ! timeout "$TIMEOUT" restic unlock --remove-all -v; then
		echo "INFO: creating new repository"
		timeout "$TIMEOUT" restic init
	fi

	check
	check_failed=$?

	echo "INFO: starting new backup"
	if [ -n "$DATA_DIRECTORY" ]; then
		restic backup ${RESTIC_ARGS} --host "${INSTANCE:-"$(hostname)"}" "${data}"
	elif [ -n "${MYSQL_DATABASE}" ]; then
		check_db_vars
		mysqldump -h "$MYSQL_HOST" --quick --compress --single-transaction --debug-info --max_allowed_packet=128MB -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" > /tmp/database.raw 
		restic backup ${RESTIC_ARGS} --host "${INSTANCE:-"$(hostname)"}" --stdin --stdin-filename "${data}" < /tmp/database.raw
	fi

	forget
	forget_failed=$?

	prune
	prune_failed=$?

	# statistics are not imporatant when not sent to monitoring
	if [ -z "$PUSHGATEWAY_URL" ]; then
		echo "INFO: PUSHGATEWAY_URL not defined, metrics won't be sent"
		exit 0
	fi

	# statistics
	echo "INFO: Backup finished, exporting statistics"
	stats=$(timeout "$TIMEOUT" restic stats --no-lock --json)
	if [ "$stats" = "" ]; then
		echo "ERROR: No backup statistics can be found. Exiting."
		exit 1
	fi

	# snapshots
	snapshots=$(timeout "$TIMEOUT" restic snapshots --no-lock --json | jq length)
	if [ "$snapshots" = "" ]; then
		echo "ERROR: No backup snapshots can be found. Exiting."
		exit 1
	fi

	cat <<EOF | curl -iv --data-binary @- "${metrics_url}" 2> /dev/null
# HELP job_success_timestamp_seconds Time when job started
# TYPE job_success_timestamp_seconds gauge
job_success_timestamp_seconds $(date +%s)
# HELP backup_size_bytes Backup size
# TYPE backup_size_bytes gauge
backup_size_bytes $(echo "$stats" | jq .total_size)
# HELP backup_files_total Total number of backed up files
# TYPE backup_files_total gauge
backup_files_total $(echo "$stats" | jq .total_file_count)
# HELP backup_snapshots_total Total number of snapshots
# TYPE backup_snapshots_total gauge
backup_snapshots_total ${snapshots}
# HELP backup_forget_failed Restic forget failure
# TYPE backup_forget_failed gauge
backup_forget_failed ${forget_failed}
# HELP backup_check_failed Restic check failure
# TYPE backup_check_failed gauge
backup_check_failed ${check_failed}
# HELP backup_prune_failed Restic prune failure
# TYPE backup_prune_failed gauge
backup_prune_failed ${prune_failed}

EOF
	echo "INFO: Statistics exported. All done."
}

check_db_vars() {
	if [ -z "$MYSQL_PASSWORD" ]; then
		echo "ERROR: MYSQL_PASSWORD is not set. Exiting"
		exit 1
	fi
	if [ -z "$MYSQL_USER" ]; then
		echo "ERROR: MYSQL_USER is not set. Exiting"
		exit 1
	fi
	if [ -z "$MYSQL_HOST" ]; then
		echo "ERROR: MYSQL_HOST is not set. Exiting"
		exit 1
	fi
}


check_restic_vars() {
	if [ -z "$RESTIC_REPOSITORY" ]; then
		echo "ERROR: RESTIC_REPOSITORY is not set. Exiting"
		exit 1
	fi
	if [ -z "$RESTIC_PASSWORD" ]; then
		echo "ERROR: RESTIC_PASSWORD is not set. Exiting"
		exit 1
	fi
	if [ -z "$DATA_DIRECTORY" ] && [ -z "$MYSQL_DATABASE" ]; then
		echo "ERROR: Either DATA_DIRECTORY or MYSQL_DATABASE is not set. Exiting"
		exit 1
	fi
}

echo "INFO: Start restic backup"
check_restic_vars

backup
