{ config, dirs, lib, pkgs, ... } @ args:

let
  customLib = import dirs.lib args;
in

customLib.containerApp rec {
  name = "plc-web-hack";

  hostName = "hack.plc.tobias-happ.de";

  containerPort = 80;
}
