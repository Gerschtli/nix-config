{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "spring-rest-api";

  hostName = "${name}.tobias-happ.de";
}
