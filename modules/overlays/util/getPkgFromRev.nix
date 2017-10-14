{ package, rev, sha256, allowUnfree ? false }:

self: super:

let
  nixpkgs = import (super.fetchFromGitHub {
    inherit rev sha256;
    owner = "NixOS";
    repo  = "nixpkgs";
  }) {
    config = { inherit allowUnfree; };
    overlays = [];
  };
in

{ ${package} = nixpkgs.${package}; }
