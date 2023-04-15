# My Nix configs

# Chromebook

## Special notes

* home-manager was acting weird with the `/nix/var/nix` file path so I had to run the suggestion from [here](https://github.com/nix-community/home-manager/issues/3734#issuecomment-1453385357): `mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER` combined with then `sudo chown $USER:$USER /nix/var/nix/profiles/per-user/$USER` this will likely bite me in the ass at some point, so hi future Phil!
