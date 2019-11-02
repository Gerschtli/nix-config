# Home Manager configurations

This repository manages all my [home manager](https://github.com/rycee/home-manager) configuration files and the
corresponding library of custom modules.

Provides `home.nix` files for each host and user in `home-files` with the structure `home-files/<host>/<user>.nix`:

* `argon`: personal laptop
* `devel-one`: work desktop
* `helium`: personal desktop
* `localhost`: android phone (based on [nix-on-droid](https://github.com/t184256/nix-on-droid-bootstrap))
* `krypton`: server
* `TOBIAS-PC`: wsl (ubuntu)
* `xenon`: raspberry pi

## Nix Channels

Run `bin/setup-nix-channels`:

```bash
./bin/setup-nix-channels [--android|--non-nixos|--small]
```
