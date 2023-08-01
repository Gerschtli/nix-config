# Nix Configurations

This is my humble flakes-only collection of all and everything needed to set up and maintain all my nixified devices.

## Features

- Automation scripts to [setup a fresh installation](files/apps/setup.sh) and
  [update the system](home/misc/util-bins/system-update.sh) easily
- Secret management in [NixOS][nixos] ([agenix][agenix]) and [home-manager][home-manager] ([homeage][homeage]) with
  [age][age]
- [nix-on-droid][nix-on-droid]-managed android phone with [home-manager][home-manager]
- One system (`neon`) set up with ephemeral root directory using [impermanence][impermanence] and btrfs
- Generated shell scripts are always linted with [shellcheck][shellcheck]
- Checks source code with [deadnix][deadnix], [statix][statix] and [nixpkgs-fmt][nixpkgs-fmt] (using
  [nix-formatter-pack][nix-formatter-pack])
- Github Actions pipeline for aarch64-linux systems
- Every output is built with Github Actions and pushed to [cachix][cachix]
- Weekly automatic flake input updates committed to master when CI passes
- Automatic deployments on all [NixOS][nixos] systems with [cachix deployment agents][cachix-deploy] after successful
  pipeline runs

## Supported configurations

- [NixOS][nixos]-managed
  - `argon` (Oracle Cloud Compute Instance)
  - `krypton` (private server)
  - `neon` (private laptop)
  - `xenon` (Raspberry Pi 3B+)
- [home-manager][home-manager]-managed
  - `M299` with Ubuntu 22.04 (work laptop)
  - `gamer` on WSL2 with Ubuntu 20.04 (windows dual boot for games and stuff)
- [nix-on-droid][nix-on-droid]-managed
  - `pixel7a`

See [flake.nix](flake.nix) for more information like `system`.

## First installation

If any of these systems need to be reinstalled, you can run:

```sh
nix run \
  --extra-experimental-features "nix-command flakes" \
  github:Gerschtli/nix-config#setup
```

### Manual instructions for some systems

#### NixOS

1. Set up like written in the [NixOS manual][nixos-manual] with image from `nix build ".#installer-image"`
1. Add the following to `configuration.nix`:
   ```nix
   {
     users.users.root.password = "nixos";
     users.users.tobias = {
       password = "nixos";
       isNormalUser = true;
       extraGroups = [ "wheel" ];
     };
   }
   ```
1. When booted in the new NixOS system, login as tobias and run setup script

#### Raspberry Pi

1. Build image
   ```sh
   nix build ".#rpi-image"
   ```
1. Copy (`dd`) `result/sd-image/*.img` to sd-card
1. Inject sd-card in raspberry and boot
1. When booted in the new NixOS system, login as tobias and run setup script

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
sh <(curl -L https://nixos.org/nix/install) --no-channel-add --no-modify-profile
. ~/.nix-profile/etc/profile.d/nix.sh
nix run \
  --extra-experimental-features "nix-command flakes" \
  github:Gerschtli/nix-config#setup

# download and install UbuntuMono from nerdfonts.com

# set login shell
chsh -s /bin/zsh

# configure inotify watcher
echo "fs.inotify.max_user_watches = 524288" | sudo tee /etc/sysctl.d/local.conf

# set default shell (needed if using home-manager to setup xsession)
sudo ln -snf bash /bin/sh
```

#### Oracle Cloud ARM Compute Instance

1. Create final boot volume

   1. Create any instance
   1. Detach boot volume

1. Create bootstrap instance

   1. Create "VM.Standard.A1.Flex"
      1. with Ubuntu 20.04
      1. 1 OCPUs and 6 GB of memory
      1. set ssh public key
      1. Attach previously created boot volume as block volume (via ISCSI)
   1. ssh into instance with `ubuntu` user
   1. Login as `root`
   1. Set ssh public key in `/root/.ssh/authorized_keys` and run [nixos-infect][nixos-infect]:
      ```sh
      cat /home/ubuntu/.ssh/authorized_keys > /root/.ssh/authorized_keys
      curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-22.05 bash -x
      ```
   1. ssh into instance with `root` user
   1. Add the following to `/etc/nixos/configuration.nix`:
      ```nix
      {
        boot.loader.grub.efiSupport = true;
        boot.loader.grub.device = "nodev";
        services.openiscsi.enable = true;
        services.openiscsi.name = "x";
      }
      ```
   1. Activate with `nixos-rebuild switch`
   1. Copy and run ISCSI mount commands from Oracle Cloud WebUI
   1. Partion mounted boot volume
   1. Install NixOS like described in [NixOS manual][nixos-manual] with following options:

      ```nix
      {
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";

        users.users.root.password = "nixos";
        users.users.tobias = {
          password = "nixos";
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };
      }
      ```

   1. Copy and run ISCSI unmount commands from Oracle Cloud WebUI
   1. Detach volume in Oracle Cloud WebUI

1. Create final instance
   1. Create instance of previously created boot volume
   1. ssh into instance with `tobias` user and password
   1. Run setup script

**Note:** This is all needed to be able to partition the volume to have more than 100MB available in `/boot`. The boot
volume of the bootstrap instance can be reused at any time.

[age]: https://age-encryption.org/
[agenix]: https://github.com/ryantm/agenix
[cachix-deploy]: https://docs.cachix.org/deploy/
[cachix-gerschtli]: https://app.cachix.org/cache/gerschtli
[cachix]: https://www.cachix.org/
[deadnix]: https://github.com/astro/deadnix
[home-manager]: https://github.com/nix-community/home-manager
[homeage]: https://github.com/jordanisaacs/homeage
[impermanence]: https://github.com/nix-community/impermanence
[nix-formatter-pack]: https://github.com/Gerschtli/nix-formatter-pack
[nix-on-droid]: https://github.com/t184256/nix-on-droid
[nixos-infect]: https://github.com/elitak/nixos-infect
[nixos-manual]: https://nixos.org/manual/nixos/stable/index.html#sec-installation
[nixos]: https://nixos.org/
[nixpkgs-fmt]: https://github.com/nix-community/nixpkgs-fmt
[shellcheck]: https://github.com/koalaman/shellcheck
[statix]: https://github.com/nerdypepper/statix

<!-- vim: set sw=2: -->
