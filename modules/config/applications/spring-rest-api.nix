{ config, lib, pkgs, ... }:

import ../../lib/container-app.nix rec {
  inherit config lib pkgs;

  name = "spring-rest-api";

  hostName = "${name}.tobias-happ.de";
}
