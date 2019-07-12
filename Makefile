.PHONY: all check deps

HADOLINT:=$(shell command -v hadolint)
ifndef HADOLINT
	HADOLINT="/tmp/hadolint"
endif

all: check

check: $(HADOLINT)
	# List files which name starts with 'Dockerfile'
	# eg. Dockerfile, Dockerfile.build, etc.
	git ls-files --exclude='Dockerfile*' --ignored | xargs --max-lines=1 ${HADOLINT} --config .hadolint.yaml

$(HADOLINT):
	curl -sL -o ${HADOLINT} "https://github.com/hadolint/hadolint/releases/download/v1.11.1/hadolint-$(shell uname -s)-$(shell uname -m)"
	chmod 700 ${HADOLINT}
