{ config, lib, pkgs, ... }:

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

    custom.programs.shell.dynamicShellInit = [
      {
        condition = "available php";

        shellAliases = {
          cinstall = "composer install";
          cupdate = "composer update";

          behat = "./vendor/bin/behat -vvv";
          ut = "./vendor/bin/phpunit";
        };
      }
    ];

  };

}
