{ config, lib, pkgs, ... }:

{
  imports = [ (import ./modules "neon") ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
    };

    system = {
      boot.mode = "efi";

      nvidia-optimus = {
        enable = true;
        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  nix = {
    package = pkgs.nixFlakes;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  systemd.suppressedSystemUnits = [ "systemd-backlight@.service" ];

  time.hardwareClockInLocalTime = true;
}
