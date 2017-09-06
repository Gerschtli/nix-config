{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom = {
    boot.device = "/dev/sda2";

    desktop = {
      enable = true;
      printing = true;
    };

    dev.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

  networking.hostName = "helium";
}
