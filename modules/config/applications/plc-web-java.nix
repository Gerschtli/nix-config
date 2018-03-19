{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "plc-web-java";

  hostName = "java.plc.tobias-happ.de";
}
