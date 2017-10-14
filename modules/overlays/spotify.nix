# update version because of unavailabilty
self: super:

let
  nixpkgs = import (super.fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs";
    rev    = "cd490dc619dd435f0607d8bca3d7ef121d87525f";
    sha256 = "12vch9favhbh62cpvbjxrprxws4z76jn2894q29mj0zym7qnapa8";
  }) {
    config   = { allowUnfree = true; };
    overlays = [];
  };
in

{ inherit (nixpkgs) spotify; }
