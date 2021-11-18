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

    # remove as soon as available in stable
    jdk17_headless
    ventoy-bin
    ;
}
