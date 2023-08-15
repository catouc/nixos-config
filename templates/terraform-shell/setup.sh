#!/usr/bin/env bash
echo "flake.nix" >> .git/info/exclude
echo "flake.lock" >> .git/info/exclude
echo ".envrc" >> .git/info/exclude
echo ".direnv" >> .git/info/exclude

echo "use flake path:$(pwd)" > .envrc
direnv allow

