{ fetchFromGitHub, rev, sha256, owner ? "NixOS" }:

let
  pinnedPkgs = fetchFromGitHub {
    inherit owner rev sha256;
    repo = "nixpkgs";
  };
in

import pinnedPkgs { overlays = [ ]; }
