# My Nix configs

# NixOS boxes

## Removing old grub entries

This [comment](https://github.com/NixOS/nixpkgs/issues/3542#issuecomment-695162502) has gotten me there to cleanup properly. TL;DR

```
sudo nix-env --delete-generations 10d --profile /nix/var/nix/profiles/system
sudo nixos-rebuild switch --flake .#$(uname -n)
```

## Connect bluetooth headphones

```
bluetoothctl scan
# fish out device ID
bluetoothctl pair <ID>
bluetoothctl connect <ID>
```

Ideally pipewire should pick this up then if you followed https://nixos.wiki/wiki/PipeWire

## Updating linux boxes

A helper script at `./hack/update` is there that will prepare the lock file, reconfigure the system and then try to add the new lock to git and commit

## Polarbar logs in `/var/log/polybar/polybar.log`

Gotta create that myself for now because I'm too lazy to actually figure this out.

```
sudo mkdir /var/log/polybar
sudo chown root:users /var/log/polybar
```

# Chromebook

## Special notes

* home-manager was acting weird with the `/nix/var/nix` file path so I had to run the suggestion from [here](https://github.com/nix-community/home-manager/issues/3734#issuecomment-1453385357): `mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER` combined with then `sudo chown $USER:$USER /nix/var/nix/profiles/per-user/$USER` this will likely bite me in the ass at some point, so hi future Phil! Future Phil was here and had to also set `sudo chown $USER:$USER /nix/var/nix/gcroots/per-user/$USER`

# Templates

List all templates with `nix flake show github:catouc/nixos-config templates`
Init a template with `nix flake init -t github:catouc/nixos-config#<template-name>`

# Dev-shells

On projects that I don't fully own that don't have nix first class support we can add our flakes with a little bit of trickery:

```
# add flake.nix
echo "flake.nix" >> ./.git/info/exclude
echo "flake.lock" >> ./.git/info/exclude
echo ".envrc" >> ./.git/info/exclude
echo ".direnv" >> ./.git/info/exclude

echo "use flake path:$(pwd)" >> .envrc
direnv allow
```

# TODO

* Move font config to shared file instead of copying it between systems
* Make the setup.sh script for my shell templates able to detect existing entires in the gitignore thing and don't add them twice
* Slash out the syntax highlighting out of the terraform-ls setup
