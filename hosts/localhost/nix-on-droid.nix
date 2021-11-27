{ pkgs, config, lib, ... }:

let
  homeDir = builtins.getEnv "HOME";
  homeFile = "${homeDir}/.config/nixpkgs/home.nix";
in

{
  environment.etcBackupExtension = ".nod-bak";

  environment.packages = with pkgs; [
    gnutar
    gzip
  ];

  home-manager = {
    backupFileExtension = "hm-bak";
    config = import homeFile;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = "19.09";

  time.timeZone = "Europe/Berlin";

  user.shell = "${pkgs.zsh}/bin/zsh";
}
