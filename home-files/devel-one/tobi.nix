{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.general.extendedPath = [
      "$HOME/bin"
      "/snap/bin"
      "$HOME/.local/share/umake/bin"
    ];

    development = {
      direnv.enable = true;

      lorri.enable = true;

      nodejs.enable = true;

      php.enable = true;

      vagrant.enable = true;
    };

    misc = {
      dotfiles.modules = [ "atom" ];

      nonNixos.enable = true;

      util-bins.bins = [ "csv-check" ];
    };

    programs = {
      shell.envExtra = ''
        export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:}$NIX_PATH
        export NIX_PROFILES="/nix/var/nix/profiles/default /nix/var/nix/profiles/per-user/$USER"
      '';

      ssh.modules = [ "private" "pveu" ];

      urxvt.enable = true;
    };

    services = {
      dunst.enable = true;

      dwm-status = {
        enable = true;
        order = [ "cpu_load" "audio" "time" ];

        extraConfig = ''
          separator = "    "

          [audio]
          mute = "ﱝ"
          template = "{ICO} {VOL}%"
          icons = ["奄", "奔", "墳"]
        '';
      };
    };

    xsession = {
      enable = true;
      useSlock = true;
    };
  };

  home = {
    packages = with pkgs; [
      # avocode
      docker_compose
      # eclipses.eclipse-sdk
      gimp
      jetbrains.idea-ultimate
      libreoffice
      mysql-workbench
      postman
      slack
      soapui
      spotify
    ];

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
  };

  services.unclutter = {
    enable = true;
    timeout = 3;
  };

  xsession.profileExtra = ''
    exec > ~/.xsession-errors 2>&1
  '';
}
