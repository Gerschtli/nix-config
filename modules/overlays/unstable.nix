self: super:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
    overlays = [ ];
  };

  pinnedPkgs = import (super.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ee939c9d1878183e84054b1b0766b76ff33d2c20";
    sha256 = "0364blqdvcahc58f577fhz7g15gz6gp8vmyxn6nzwpv73zq6hp7j";
  }) {
    config = { allowUnfree = true; };
    overlays = [ ];
  };
in

{
  inherit (unstable)
    #jetbrains         # need bleeding edge version
    liquidprompt      # need version 1.12.0
    teamspeak_server  # need bleeding edge version
    terraform         # need bleeding edge version
  ;

  inherit (pinnedPkgs) jetbrains;
}
