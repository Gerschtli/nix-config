self: super:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
    overlays = [ ];
  };
in

{
  inherit (unstable)
    # need bleeding edge version
    jetbrains
    portfolio
    teamspeak_server

    ventoy-bin
  ;

  nnn = unstable.nnn.override { withNerdIcons = true; };
}
