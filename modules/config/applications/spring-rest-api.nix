{ config, dirs, lib, pkgs, ... } @ args:

let
  customLib = import dirs.lib args;
in

customLib.containerApp rec {
  name = "spring-rest-api";

  hostName = "${name}.tobias-happ.de";
}
