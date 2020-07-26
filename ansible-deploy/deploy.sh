#!/bin/bash

ARA_SERVER="${ARA_SERVER:-""}"
PUSHGATEWAY_URL="${PUSHGATEWAY_URL:-""}"
PLAYBOOK_NAME="${PLAYBOOK_NAME:-"site.yml"}"
PLAYBOOK_DIR="${PLAYBOOK_DIR:-"ansible"}"
REPO_URL="${REPO_URL:-""}"
REPO_DIR="${REPO_DIR:-"/ansible"}"
MAX_AGE="${MAX_AGE:-"$(( 12*60*60 ))"}"

metrics_start() {
	if [ -z "$PUSHGATEWAY_URL" ]; then
		echo "INFO: PUSHGATEWAY_URL not defined, metrics not sent"
		return
	fi
	cat <<EOF | curl --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/deploy"
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
	echo "INFO: Startup statistics exported."
}

metrics_success() {
	if [ -z "$PUSHGATEWAY_URL" ]; then
		echo "INFO: PUSHGATEWAY_URL not defined, metrics not sent"
	fi
	cat <<EOF | curl --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/deploy"
# HELP job_success_timestamp_seconds Time when job started
# TYPE job_success_timestamp_seconds gauge
job_success_timestamp_seconds $(date +%s)
EOF
	echo "INFO: Statistics exported. All done."
}

update_repo() {
	if [ ! -d .git ]; then
		echo "INFO: Repository not found locally. Downloading ${REPO_URL}"
		git clone "${REPO_URL}" .
	fi

	echo "INFO: Updating code repository"
	# Clean repository and revert all local changes
	git clean -xfd
	git reset --hard HEAD
	git pull
}

update_hosts() {
	if curl -fsSL "${ARA_SERVER}/api/" >/dev/null && python3 -c "import ara.setup.callback_plugins"; then
		export ARA_API_CLIENT="http"
		export ARA_API_SERVER="${ARA_SERVER}"
		export ANSIBLE_CALLBACK_PLUGINS="$(python3 -m ara.setup.callback_plugins)"
		export ANSIBLE_DISPLAY_OK_HOSTS=no
		export ANSIBLE_DISPLAY_SKIPPED_HOSTS=no
		echo "INFO: Connection to ARA extablished. Disabling showing unchanged and skipped tasks."
	else
		echo "WARN: Couldn't contact ARA server. Ansible run won't be recorded."
	fi
	echo "INFO: Updating services"
	
	cd "${REPO_DIR}/${PLAYBOOK_DIR}"
	ansible-galaxy install --force -r roles/requirements.yml
	ansible-playbook "${PLAYBOOK_NAME}" 3>&1 || exit 1
}

echo "INFO: Start update at $(date)"

set -euo pipefail

cd "${REPO_DIR}"

metrics_start

update_repo

update_hosts

metrics_success
