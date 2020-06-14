#!/bin/sh

RESTIC_REPOSITORY=${RESTIC_REPOSITORY:-""}
RESTIC_PASSWORD=${RESTIC_PASSWORD:-""}
DATA_DIRECTORY=${DATA_DIRECTORY:-""}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}

RESTIC_ARGS=${1:-""}

PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-""}"
INSTANCE=${INSTANCE:-"$(hostname)"}

TIMEOUT="10m"

set -euo pipefail

backup() {
	echo "$(date +"%F %T") INFO: Releasing all locks"
	if ! timeout $TIMEOUT restic unlock --remove-all -v; then
		echo "$(date +"%F %T") INFO: creating new repository"
		timeout $TIMEOUT restic init
	fi

	echo "$(date +"%F %T") INFO: checking repository state"
	timeout $TIMEOUT restic check

	echo "$(date +"%F %T") INFO: starting new backup"
	start=$(date +%s)
	if [ -n "$DATA_DIRECTORY" ]; then
		restic backup ${RESTIC_ARGS} --host "${INSTANCE}" "${DATA_DIRECTORY}"
		DATA="${DATA_DIRECTORY}"
	elif [ -n "${MYSQL_DATABASE}" ]; then
		check_db_vars
		mysqldump -h "$MYSQL_HOST" --single-transaction -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" | restic backup ${RESTIC_ARGS} --host "${INSTANCE}" --stdin --stdin-filename "${MYSQL_DATABASE}_dump.sql"
		DATA="${MYSQL_DATABASE}_dump.sql"
	fi
	end=$(date +%s)

	echo "$(date +"%F %T") INFO: Backup finished, exporting statistics"
	STATS=$(restic stats --json)
	echo "$STATS"
	if [ "$STATS" = "" ]; then
		echo "$(date +"%F %T") ERROR: No backup statistics can be found. Exiting."
		exit 1
	fi

	if [ -z "$PUSHGATEWAY_URL" ]; then
		echo "INFO: PUSHGATEWAY_URL not defined, metrics won't be sent"
	else
		cat <<EOF | curl --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/backup/instance/${INSTANCE}" > /dev/null
# HELP backup_duration_seconds Time spent on creating backup
# TYPE backup_duration_seconds gauge
backup_duration_seconds{repository="${RESTIC_REPOSITORY}",data="${DATA}"} $((end - start))
# HELP backup_size_bytes Backup size
# TYPE backup_size_bytes gauge
backup_size_bytes{repository="${RESTIC_REPOSITORY}",data="${DATA}"} $(echo $STATS | jq .total_size)
# HELP backup_files_total Total number of backed up files
# TYPE backup_files_total gauge
backup_files_total{repository="${RESTIC_REPOSITORY}",data="${DATA}"} $(echo $STATS | jq .total_file_count)
EOF
		echo "$(date +"%F %T") INFO: Statistics exported. All done."
	fi
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

echo "$(date +"%F %T") INFO: Start restic backup"
check_restic_vars

backup
