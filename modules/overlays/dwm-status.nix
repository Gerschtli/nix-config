self: super:

let
  # PR branch to update dwm-status to 1.4.0
  pkgs = let
    pinnedPkgs = super.fetchFromGitHub {
      owner = "Gerschtli";
      repo = "nixpkgs";
      rev = "6760af490e5e9e99dbdd80967055c83e91c0c457";
      sha256 = "0cdwhgsfy88h97gwn7c130gkbf9lj85mzf4xhqqps0npfkscqpn0";
    };
  in import pinnedPkgs { };
in

{ inherit (pkgs) dwm-status; }
