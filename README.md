# NixOS configurations

This repository manages all my NixOS configuration files and the corresponding library of custom
modules.

## Nodes

* *helium*: tower
* *neon*: server
* *argon*: laptop
* *krypton*: server

## Set up

You need to link any configuration file first:
```bash
$ ln -sf configuration-<host>.nix configuration.nix
```

## Rebuild system

It is recommended to use `bin/rebuild <test|switch|...>` instead of plain `nixos-rebuild` because
the script will generate necessary diffs and will ensure the right permissions of ssh keys.
