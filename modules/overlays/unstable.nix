self: super:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
    overlays = [ ];
  };
in

{
  inherit (unstable)
    jetbrains         # need bleeding edge version
    pipenv
    teamspeak_server  # need bleeding edge version
  ;
}
