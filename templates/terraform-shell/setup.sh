#!/usr/bin/env bash
echo "use flake" > .envrc
direnv allow

echo "flake.nix" >> .git/info/exclude
echo "flake.lock" >> .git/info/exclude
echo ".envrc" >> .git/info/exclude
