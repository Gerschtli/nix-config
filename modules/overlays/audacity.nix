self: super:

let
  pkgs = import (super.fetchFromGitHub {
    name = "nixpkgs-for-audacity-fix";
    owner = "Gerschtli";
    repo = "nixpkgs";
    rev = "f30631265c8a9d51d0e60a02ceee096dbe784c14";
    sha256 = "1b61z9mqy57qjwn5nydyxwqgng2axp6gf2sgw6ac2ics4di1av8i";
  }) {
    config = { };
    overlays = [ ];
  };
in

{ inherit (pkgs) audacity; }
