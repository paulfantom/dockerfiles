#!/bin/sh

RESTIC_REPOSITORY=${RESTIC_REPOSITORY:-""}
RESTIC_PASSWORD=${RESTIC_PASSWORD:-""}
WHEN=${WHEN:-"01:00"}
DATA_DIRECTORY=${DATA_DIRECTORY:-""}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}

RESTIC_ARGS=${RESTIC_ARGS:-""}
RESTIC_FORGET=${RESTIC_FORGET:-""}

PARAM=${1:-""}

set -euo pipefail

COUNTER=0
reset() {
	if [ -n "$DATA_DIRECTORY" ]; then
            DATA="${DATA_DIRECTORY}"
        elif [ -n "${MYSQL_DATABASE}" ]; then
            DATA="${MYSQL_DATABASE}_dump.sql"
        fi
        NAME="$(echo "restic_${RESTIC_REPOSITORY}_${DATA}" | tr -c '[:alnum:].-' _)"
        cat <<EOF > "/metrics/${NAME}.prom"
# HELP backup_executions_total Number of backup executions
# TYPE backup_executions_total counter
backup_executions_total{repository="${RESTIC_REPOSITORY}",data="${DATA}"} 0
EOF
	sleep 60
}

backup() {
        echo "$(date +"%F %T") INFO: Releasing all locks"
        restic unlock --remove-all
        echo "$(date +"%F %T") INFO: checking repository state"
        restic check
        echo "$(date +"%F %T") INFO: starting new backup"
        start=$(date +%s)
        if [ -n "$DATA_DIRECTORY" ]; then
            restic backup ${RESTIC_ARGS} "${DATA_DIRECTORY}"
            DATA="${DATA_DIRECTORY}"
        elif [ -n "${MYSQL_DATABASE}" ]; then
            check_db_vars
            mysqldump -h "$MYSQL_HOST" --single-transaction -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" | restic backup ${RESTIC_ARGS} --stdin --stdin-filename "${MYSQL_DATABASE}_dump.sql"
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
        
        COUNTER=$((COUNTER+=1))
        NAME="$(echo "restic_${RESTIC_REPOSITORY}_${DATA}" | tr -c '[:alnum:].-' _)"
        cat <<EOF > "/metrics/${NAME}.prom"
# HELP backup_executions_total Number of backup executions
# TYPE backup_executions_total counter
backup_executions_total{repository="${RESTIC_REPOSITORY}",data="${DATA}"} $COUNTER
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

forget() {
        if [ -n "$RESTIC_FORGET" ]; then
        	echo "$(date +"%F %T") INFO: Forgetting and cleaning up repository. Options used: $RESTIC_FORGET"
                #shellcheck disable=SC2086
                restic forget --prune $RESTIC_FORGET
        fi
}

if [ -z "$WHEN" ]; then
        echo "ERROR: WHEN is not set. Exiting"
        exit 1
fi
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

echo "$(date +"%F %T") INFO: Start restic backup script"
reset

if [ "$PARAM" = "--now" ]; then
    echo "$(date +"%F %T") INFO: Forcing backup execution at startup"
    backup
fi

while true; do
        sleep 30
        if [ "$(date +%H:%M)" = "$WHEN" ]; then
                backup
                forget
                sleep 12h
        fi
done
