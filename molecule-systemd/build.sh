#!/bin/bash

set -euo pipefail

prefix="quay.io/paulfantom/molecule-systemd"
git_commit="$(git rev-parse --short HEAD)"

#for distro in $(ls -d */ | tr -d '/'); do
#	echo "=== BUILDING $distro ==="
#	docker build -f "$distro/Dockerfile" -t "$prefix:$distro" "$distro"
#	docker tag "$prefix:$distro" "$prefix:$distro-$git_commit"
#done

for distro in $(ls -d */ | tr -d '/'); do
	echo "=== PUSHING $prefix:$distro ==="
	docker push "$prefix:$distro"
	docker push "$prefix:$distro-$git_commit"
done


