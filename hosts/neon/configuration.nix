{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxKernel.packageAliases.linux_latest;

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

  systemd.suppressedSystemUnits = [ "systemd-backlight@backlight:acpi_video0.service" ];

  time.hardwareClockInLocalTime = true;
}
