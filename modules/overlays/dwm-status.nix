# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/52716 got merged

self: super:

let
  # PR branch to update dwm-status to 1.5.0
  pkgs = let
    pinnedPkgs = super.fetchFromGitHub {
      owner = "Gerschtli";
      repo = "nixpkgs";
      rev = "a08b98f0c17650da609e4331f5058ca2177471af";
      sha256 = "009k2f00dma2441rcghci3dsglar30skjlfjz45cd19inb9b4d3x";
    };
  in import pinnedPkgs { overlays = []; };
in

{ inherit (pkgs) dwm-status; }
