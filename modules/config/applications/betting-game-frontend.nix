{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "betting-game-frontend";

  hostName = "bg.tobias-happ.de";

  containerPort = 80;
}
