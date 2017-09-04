{ config, pkgs, ... }:

{
  services.mysql = {
    # set password with:
    # SET PASSWORD FOR root@localhost = PASSWORD('password');
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/var/db/mysql";
  };
}
