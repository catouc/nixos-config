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

# Chromebook

## Special notes

* home-manager was acting weird with the `/nix/var/nix` file path so I had to run the suggestion from [here](https://github.com/nix-community/home-manager/issues/3734#issuecomment-1453385357): `mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER` combined with then `sudo chown $USER:$USER /nix/var/nix/profiles/per-user/$USER` this will likely bite me in the ass at some point, so hi future Phil! Future Phil was here and had to also set `sudo chown $USER:$USER /nix/var/nix/gcroots/per-user/$USER`

# TODO

* Move font config to shared file instead of copying it between systems
* Think about moving all of the home manager modules into the flake.nix instead of inside of a layer of indirection, then just create a `workpackages` and `personalpackages` module?
