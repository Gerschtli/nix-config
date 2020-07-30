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
    rustup            # FIXME: needs https://github.com/NixOS/nixpkgs/pull/91327
    teamspeak_server  # need bleeding edge version
    terraform         # need bleeding edge version
  ;
}
