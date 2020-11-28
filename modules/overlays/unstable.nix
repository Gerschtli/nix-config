self: super:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
    overlays = [ ];
  };
in

{
  inherit (unstable)
    google-cloud-sdk  # need bleeding edge version
    jetbrains         # need bleeding edge version
    terraform         # need bleeding edge version
  ;
}
