#!/bin/bash

for component in */; do
	if [ ! -f "$component/VERSION" ]; then
		continue
	fi
	reposlug=$(grep repository "$component/Dockerfile" | sed 's|# repository: https://github.com/||')
	if [ "$reposlug" == "" ]; then
		continue
	fi
        url="https://api.github.com/repos/$reposlug/releases/latest"
	version=$(curl --silent "$url" | grep -Po '"tag_name": "\K.*?(?=")' | tr -d v)
	echo "Latest version of $component is $version"
	echo "$version" > "$component/VERSION"
done
