.PHONY: all check deps

HADOLINT:=$(shell command -v hadolint)

all: check

check: deps
	# List files which name starts with 'Dockerfile'
	# eg. Dockerfile, Dockerfile.build, etc.
	git ls-files --exclude='Dockerfile*' --ignored | xargs --max-lines=1 ${HADOLINT} --config .hadolint.yaml

deps:
ifndef HADOLINT
	HADOLINT=/tmp/hadolint
	curl -sL -o /tmp/hadolint "https://github.com/hadolint/hadolint/releases/download/v1.11.1/hadolint-$(uname -s)-$(uname -m)"
	chmod 700 ${HADOLINT}
endif
