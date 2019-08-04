{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.misc.nonNixos;
in

{

  ###### interface

  options = {

    custom.misc.nonNixos.enable = mkEnableOption "config for non NixOS systems";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home = {
      packages = [ pkgs.nix ];

      sessionVariables = {
        # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
        LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
        LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
      };
    };

    programs = {
      bash.profileExtra = ''
        source "${pkgs.nix}/etc/profile.d/nix.sh"
      '';

      zsh.envExtra = ''
        source "${pkgs.nix}/etc/profile.d/nix.sh"
        hash -f
      '';
    };

  };

}
