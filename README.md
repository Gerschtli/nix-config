# Nix Configurations

This is my humble flakes-only collection of all and everything needed to set up and maintain all my nixified devices.

## Features

* Automation scripts to [setup a fresh installation](files/apps/setup.sh) and
  [update the system](home/misc/util-bins/system-update.sh) easily
* Secret management in [NixOS][nixos] ([agenix][agenix]) and [home-manager][home-manager] ([homeage][homeage]) with
  [age][age]
* [nix-on-droid][nix-on-droid]-managed android phone with [home-manager][home-manager]
* Generated shell scripts are always linted with [shellcheck][shellcheck]
* Checks source code with [statix][statix] and [nixpkgs-fmt][nixpkgs-fmt]
* Every output is built with Github Actions and pushed to [cachix][cachix]
* Weekly automatic flake input updates committed to master when CI passes

## Supported configurations

* [NixOS][nixos]-managed
  * `argon` (Oracle Cloud Compute Instance)
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

If any of these systems need to be reinstalled, you can run:

```sh
$ nix run github:Gerschtli/nix-config#setup
```

**Note:**
* NixOS-managed systems should be set up like written in the [NixOS manual][nixos-manual].
* For the Raspberry Pi use the provided script in [misc/sd-image.nix](misc/sd-image.nix) to create the sd-card image.

### Manual instructions for some systems

#### nix-on-droid

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
nix-shell -p nix --run "nix run github:Gerschtli/nix-config#setup"
```

#### Raspberry Pi

1. Build image
   ```sh
   nix build ".#rpi-image"
   ```
1. Copy (`dd`) `result/sd-image/*.img` to sd-card
1. Mount sd-card and run
   ```sh
   wpa_passphrase ESSID PSK > /mnt/etc/wpa_supplicant.conf
   ```
1. Unmount, inject sd-card in raspberry and boot

##### Update firmware

Firmware of Raspberry Pi needs to be updated manually on a regular basis with the following steps:

1. Build firmware
   ```sh
   nix build ".#rpi-firmware"
   ```
1. Mount `/dev/disk/by-label/FIRMWARE`
1. Create backup of all files
1. Copy `result/*` to firmware partition (ensure that old ones are deleted)
1. Unmount and reboot

#### Ubuntu 20.04

```sh
# update and install system packages
sudo apt update
sudo apt upgrade
sudo apt install zsh

# install nix setup
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
sh <(curl -L https://nixos.org/nix/install) --no-channel-add --no-modify-profile
. ~/.nix-profile/etc/profile.d/nix.sh
nix run github:Gerschtli/nix-config#setup

# download and install UbuntuMono from nerdfonts.com

# set login shell
chsh -s /bin/zsh

# configure inotify watcher
echo "fs.inotify.max_user_watches = 524288" | sudo tee /etc/sysctl.d/local.conf

# set default shell (needed if using home-manager to setup xsession)
sudo ln -snf bash /bin/sh
```

#### Oracle Cloud ARM Compute Instance

1. Create "VM.Standard.A1.Flex"
   1. with Ubuntu 20.04
   1. 4 OCPUs and 24 GB of memory
   1. set ssh public key
1. ssh into instance with `ubuntu` user
1. Login as `root`
1. Set ssh public key in `/root/.ssh/authorized_keys`
1. Run [nixos-infect][nixos-infect] like
   ```sh
   curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-22.05 bash -x
   ```
1. ssh into instance with `root` user
1. Run setup script like
   ```sh
   nix run --extra-experimental-features flakes --extra-experimental-features nix-command github:Gerschtli/nix-config#setup
   ```

## TODOs

As I am currently transitioning to a flake setup, there is still some stuff to do :)

* [ ] NixOS setup script: `/run/user/1000` is not created and `/home/tobias/.age` is missing
* [ ] Add functionality to apply patches to individual inputs (EDIT: non-trivial because `builtins.getFlake` does not
  accept paths to `/nix/store`..)
* [ ] Let all servers fetch latest version of this repo regularly and apply configuration
* [ ] Provide ISO-images for NixOS configurations
* [ ] Set up nixos-shell and similar for an ubuntu image to easily test setup script
* [ ] Fix homeage: age files are not gcroots + home-manager service fails on system startup
* [ ] [systemd-boot-builder.py][systemd-boot-builder.py] does not clean up boot loader entries of specialisations, try
  to improve this script

[age]: https://age-encryption.org/
[agenix]: https://github.com/ryantm/agenix
[cachix]: https://www.cachix.org/
[cachix-gerschtli]: https://app.cachix.org/cache/gerschtli
[home-manager]: https://github.com/nix-community/home-manager
[homeage]: https://github.com/jordanisaacs/homeage
[nix-on-droid]: https://github.com/t184256/nix-on-droid
[nixos-infect]: https://github.com/elitak/nixos-infect
[nixos-manual]: https://nixos.org/manual/nixos/stable/index.html#sec-installation
[nixos]: https://nixos.org/
[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[shellcheck]: https://github.com/koalaman/shellcheck
[statix]: https://github.com/nerdypepper/statix
[systemd-boot-builder.py]: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/loader/systemd-boot/systemd-boot-builder.py

<!-- vim: set sw=2: -->
