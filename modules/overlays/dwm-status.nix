self: super:

let
  # PR branch to update dwm-status to 1.4.1
  pkgs = let
    pinnedPkgs = super.fetchFromGitHub {
      owner = "Gerschtli";
      repo = "nixpkgs";
      rev = "bc2d26fd8f5f0e179cb739817b220bfa81da950e";
      sha256 = "00wagg5c6vsyk8fvb8wcv1y5mg1y6qd35qpzs03n86csq8sqdr2b";
    };
  in import pinnedPkgs { overlays = []; };
in

{ inherit (pkgs) dwm-status; }
