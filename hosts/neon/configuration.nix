{ config, lib, pkgs, ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # FIXME: remove when 22.11 is released
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_19;

  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
    };

    cachix-agent.enable = true;

    programs.docker.enable = true;

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
}
