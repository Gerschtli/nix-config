{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = false;
      };
    };

    development.nix.nix-on-droid.enable = true;

    programs.ssh = {
      controlMaster = "no";
      modules = [ "private" ];
    };
  };

  home = {
    packages = with pkgs; [
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

    sessionVariables =
      let
        profiles = [ "/nix/var/nix/profiles/default" "$HOME/.nix-profile" ];
        dataDirs =
          lib.concatStringsSep ":" (map (profile: "${profile}/share") profiles);
      in
      {
        XDG_DATA_DIRS = "${dataDirs}\${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS";
      };
  };
}
