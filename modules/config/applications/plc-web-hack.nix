{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "plc-web-hack";

  hostName = "hack.plc.tobias-happ.de";
}
