{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.pass;

  # see dmenucmd in dwm config
  dmenuCmd = ''dmenu -fn "UbuntuMono Nerd Font:size=9" -nb "#222222" -nf "#bbbbbb" -sb "#540303" -sf "#eeeeee"'';

  package = pkgs.pass.overrideAttrs (_old: {
    postBuild = ''
      sed -i -e 's@"$dmenu"@${dmenuCmd}@' contrib/dmenu/passmenu
    '';
  });
in

{

  ###### interface

  options = {

    custom.programs.pass = {
      enable = mkEnableOption "pass config";

      browserpass = mkEnableOption "browserpass";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.gpg.enable = true;

    programs = {
      browserpass = {
        enable = cfg.browserpass;
        browsers = [ "chrome" ];
      };

      password-store = {
        inherit package;
        enable = true;
        settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      };
    };

  };

}
