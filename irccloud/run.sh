#!/bin/sh

if [ -z "${IRCCLOUD_USERNAME+x}" ]; then
	echo "ERROR: IRCCLOUD_USERNAME not specified"
	exit 1
fi

if [ -z "${IRCCLOUD_PASSWORD+x}" ]; then
	echo "ERROR: IRCCLOUD_PASSWORD not specified"
	exit 1
fi

export IRCCLOUD_USERNAME
export IRCCLOUD_PASSWORD

python "/usr/local/src/irccloud/irccloud.py"
