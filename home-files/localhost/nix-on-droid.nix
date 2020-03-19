{ config, lib, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = false;
      };
    };

    misc.dotfiles.modules = [ "nix-on-droid" ];

    programs = {
      shell = {
        envExtra = lib.mkOrder 0 ''
          source "/data/data/com.termux.nix/files/home/.nix-profile/etc/profile.d/nix-on-droid-session-init.sh"
        '';

        initExtra = ''
          if [ -z "''${SSH_AUTH_SOCK:-}" ]; then
            eval $(ssh-agent -s)
          fi
        '';
      };

      ssh = {
        enableKeychain = false;
        controlMaster = "no";
        modules = [ "private" ];
      };

      tmux.enable = lib.mkForce false;
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
  };
}
