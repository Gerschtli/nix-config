{ config, lib, pkgs, ... }:

{
  imports = [ (import ./modules "neon") ];

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

  systemd.suppressedSystemUnits = [ "systemd-backlight@.service" ];

  time.hardwareClockInLocalTime = true;
}
