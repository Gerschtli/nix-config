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
    neovim            # did not built on aarch64-linux, wait for https://github.com/NixOS/nixpkgs/pull/61588
    neovim-unwrapped  # did not built on aarch64-linux, wait for https://github.com/NixOS/nixpkgs/pull/61588
    postman           # src did not exist anymore, wait for https://github.com/NixOS/nixpkgs/pull/58944
    #teamspeak_server  # need bleeding edge version
  ;

  # do not exist in stable yet
  vimPlugins = (super.vimPlugins or {}) // {
    inherit (unstable.vimPlugins) gitignore-vim vim-hybrid-material vim-tmux;
  };
}
