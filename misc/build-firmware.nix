# Build latest firmware for raspberry pi
# 1. Build
#       nix-build "<nixpkgs/nixos>" -I nixos-config=misc/build-firmware.nix -A config.system.build.firmware
# 2. Mount /dev/disk/by-label/FIRMWARE
# 3. Create backup of all files
# 4. Copy result/* to firmware partition (ensure that old ones are deleted)
# 5. Unmount and reboot

{ config, pkgs, ... }:

{
  imports = [ ./sd-image.nix ];

  system.build.firmware = pkgs.runCommand "firmware" {} ''
    mkdir firmware $out

    ${config.sdImage.populateFirmwareCommands}

    cp -r firmware/* $out
  '';
}
