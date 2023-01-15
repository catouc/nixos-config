#!/usr/bin/env bash
package_name="$1"

echo "use flake" > .envrc
direnv allow
mv cmd/replace cmd/"$package_name"
find . -type f -exec sed -i "s/replace/$package_name/g" {} \;
