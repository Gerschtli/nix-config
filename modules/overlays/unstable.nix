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
    liquidprompt      # need version 1.12.0
    teamspeak_server  # need bleeding edge version
    terraform         # need bleeding edge version
  ;
}
