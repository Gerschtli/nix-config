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
    teamspeak_server  # need bleeding edge version
  ;

  # do not exist in stable yet
  vimPlugins = (super.vimPlugins or {}) // {
    inherit (unstable.vimPlugins) gitignore-vim vim-hybrid-material vim-tmux;
  };
}
