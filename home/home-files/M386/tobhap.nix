{ config, lib, pkgs, ... }:

with lib;

let
  homeDirectory = "/home/tobhap";
  username = "tobhap";
in

{
  imports = [ ../../modules ];

  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development.nix.home-manager.enable = true;

    misc = {
      sdks = {
        enable = true;
        links = {
          inherit (pkgs.nur-gerschtli) jdk15;
          inherit (pkgs) jdk8 jdk11 jdk17_headless;
        };
      };

      work = {
        enable = true;
        directory = "sedo";
        mailAddress = "tobias.happ@sedo.com";
      };
    };

    programs.ssh.modules = [ "sedo" ];
  };

  home = {
    inherit homeDirectory username;

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
  };

  # FIXME: move to non-nixos.setupNixpkgs when hm 21.11 is released
  nixpkgs = {
    config = import (config.lib.custom.path.files + "/config.nix");
    overlays = map import (config.lib.custom.getFileList config.lib.custom.path.overlays);
  };
}
