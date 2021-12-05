{ homeModules, rootPath }:

{ config, lib, pkgs, ... }:

{
  environment.etcBackupExtension = ".nod-bak";

  environment.packages = with pkgs; [
    gnutar
    gzip
  ];

  home-manager = {
    backupFileExtension = "hm-bak";
    config = import (rootPath + "/hosts/oneplus5/home-nix-on-droid.nix") { inherit homeModules rootPath; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix = {
    package = pkgs.nix_2_4;
    extraConfig = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "21.11";

  time.timeZone = "Europe/Berlin";

  user.shell = "${pkgs.zsh}/bin/zsh";
}
