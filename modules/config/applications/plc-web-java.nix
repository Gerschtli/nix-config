{ config, dirs, lib, pkgs, ... } @ args:

let
  customLib = import dirs.lib args;
in

customLib.containerApp rec {
  name = "plc-web-java";

  hostName = "java.plc.tobias-happ.de";
}
