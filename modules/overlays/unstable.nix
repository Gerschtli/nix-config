self: super:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
    overlays = [ ];
  };
in

{
  inherit (unstable)
    audacity          # FIXME: remove if https://github.com/NixOS/nixpkgs/commit/de1d520b58f2d9d771e54492dfda8b8981c9500d is in stable
    google-cloud-sdk  # need bleeding edge version
    jetbrains         # need bleeding edge version
    terraform         # need bleeding edge version
  ;
}
