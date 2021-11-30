# Nix Configurations

This is my humble flakes-only collection of all and everything needed to set up and maintain all my nixified devices.

## Features

* Automation scripts to [setup a fresh installation](nixos/applications/tobias-happ/setup.sh) and
  [update the system](home/misc/util-bins/system-update.sh) easily
* Secret management in [NixOS][nixos] ([agenix][agenix]) and [home-manager][home-manager] ([homeage][homeage]) with
  [age][age]
* [nix-on-droid][nix-on-droid]-managed android phone with [home-manager][home-manager]
* Generated shell scripts are always linted with [shellcheck][shellcheck]

## Supported configurations

* [NixOS][nixos]-managed
  * `krypton` (private server)
  * `neon` (private laptop)
  * `xenon` (Raspberry Pi 3B+)
* [home-manager][home-manager]-managed
  * `M386` with Ubuntu 20.04 (work laptop)
  * `gamer` on WSL2 with Ubuntu 20.04 (windows dual boot for games and stuff)
* [nix-on-droid][nix-on-droid]-managed
  * `oneplus5`

See [flake.nix](flake.nix) for more information like `system`.

## First installation

If any of these systems need to be reinstalled, you can use
[nixos/applications/tobias-happ/setup.sh](nixos/applications/tobias-happ/setup.sh) or the hosted version available at
<https://tobias-happ.de/setup.sh> and just run it.

**Note:**
* NixOS-managed systems should be set up like written in the [NixOS manual][nixos-manual].
* For the Raspberry Pi use the provided script in [misc/sd-image.nix](misc/sd-image.nix) to create the sd-card image.
* For home-manager-managed systems there are several manual steps needed to set up, see the README in the respective
  directory in [hosts](hosts).

## TODOs

As I am currently transitioning to a flake setup, there is still some stuff to do :)

* [ ] Add functionality to apply patches to individual inputs (EDIT: non-trivial because `builtins.getFlake` does not
  accept paths to `/nix/store`..)
* [ ] Flakify nix profiles
* [ ] Add fenced syntax highlighting for vim [vim-nix fork of rummik][rummik/vim-nix]
* [ ] Build all configurations with Github Actions and push everything to [cachix][cachix]
* [ ] Update flake inputs regularly via Github Actions cronjob
* [ ] Let all servers fetch latest version of this repo regularly and apply configuration
* [ ] Upgrade all systems to this flake setup
* [ ] Move setup script to a flake app
* [ ] Merge host-specific READMEs
* [ ] Implement a clean up migration for the deprecated channel setup
* [ ] Add some checks like [statix][statix] and [nixpkgs-fmt][nixpkgs-fmt]
* [ ] Flakify scripts in [misc](misc)
* [ ] Provide ISO-images for NixOS configurations
* [ ] Set up nixos-shell and similar for an ubuntu image to easily test setup script
* [ ] Pin nixpkgs version in nix registry via home-manager config


[age]: https://age-encryption.org/
[agenix]: https://github.com/ryantm/agenix
[cachix]: https://www.cachix.org/
[home-manager]: https://github.com/nix-community/home-manager
[homeage]: https://github.com/jordanisaacs/homeage
[nix-on-droid]: https://github.com/t184256/nix-on-droid
[nixos-manual]: https://nixos.org/manual/nixos/stable/index.html#sec-installation
[nixos]: https://nixos.org/
[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[rummik/vim-nix]: https://github.com/rummik/vim-nix
[shellcheck]: https://github.com/koalaman/shellcheck
[statix]: https://github.com/nerdypepper/statix
[systemd-boot-patch]: https://github.com/NixOS/nixpkgs/commit/13fad0f81b2bd50fd421bd5856a35f1f7c032257

<!-- vim: set sw=2: -->
