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

    # need bleeding edge version
    google-cloud-sdk
    jetbrains
    portfolio
    teamspeak_server
    terraform

    jdk16
  ;

  nnn = unstable.nnn.override { withNerdIcons = true; };
}
