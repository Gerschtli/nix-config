{ config, pkgs, ... }:

{
  imports = [
    ./virtualbox.nix
  ];

  networking.extraHosts = ''
    # astarget
    192.168.35.10   www.astarget.local   fb.astarget.local
    192.168.35.10   test.astarget.local  test.fb.astarget.local

    # cbn/backend
    192.168.56.202  backend.local

    # cbn/frontend
    192.168.56.201  www.accessoire.local.de
    192.168.56.201  www.getprice.local.at
    192.168.56.201  www.getprice.local.ch
    192.168.56.201  www.getprice.local.de
    192.168.56.201  www.handys.local.com
    192.168.56.201  www.preisvergleich.local.at
    192.168.56.201  www.preisvergleich.local.ch
    192.168.56.201  www.preisvergleich.local.eu
    192.168.56.201  www.preisvergleich.local.org
    192.168.56.201  www.shopping.local.at
    192.168.56.201  www.shopping.local.ch
    192.168.56.201  www.testit.local.de
  '';
}
