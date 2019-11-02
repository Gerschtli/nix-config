{ config, pkgs, ... }:

let
  nix-on-droid = import <nix-on-droid> { };
in

{
  imports = [ ../../modules ];

  custom = {
    base.general.lightWeight = true;

    programs = {
      shell.initExtra = ''
        if [[ -z "$SSH_AUTH_SOCK" ]]; then
          eval $(ssh-agent -s)
        fi
      '';

      ssh = {
        enableKeychain = false;
        controlMaster = "no";
        modules = [ "private" ];
      };
    };
  };

  home = {
    packages = with pkgs; [
      nix-on-droid.basic-environment

      diffutils
      findutils
      gawk
      glibc.bin
      gnugrep
      gnused
      hostname
      man
      ncurses
    ];

    sessionVariables = {
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
  };
}
