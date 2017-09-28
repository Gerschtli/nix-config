{ package, rev, sha256 }:

self: super:

let
  nixpkgs = import (super.fetchFromGitHub {
    inherit rev sha256;
    owner = "NixOS";
    repo  = "nixpkgs";
  }) { overlays = []; };
in

{ ${package} = nixpkgs.${package}; }
