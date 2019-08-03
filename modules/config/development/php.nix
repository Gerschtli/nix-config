{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.php;
in

{

  ###### interface

  options = {

    custom.development.php.enable = mkEnableOption "php aliases";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.initExtra = ''
      if available php; then
        alias cinstall="composer install"
        alias cupdate="composer update"

        alias behat="./vendor/bin/behat -vvv"
        alias ut="./vendor/bin/phpunit"
      fi
    '';

  };

}
