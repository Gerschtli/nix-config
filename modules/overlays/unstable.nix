self: super:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
    overlays = [ ];
  };
in

{
  inherit (unstable) jetbrains postman;

  vimPlugins = (super.vimPlugins or {}) // {
    inherit (unstable.vimPlugins) gitignore-vim vim-hybrid-material vim-tmux;
  };
}
