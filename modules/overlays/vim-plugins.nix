self: super:

{
  vimPlugins = (super.vimPlugins or {}) // {
    gitignore-vim = super.vimUtils.buildVimPluginFrom2Nix {
      pname = "gitignore-vim";
      version = "2014-03-16";
      src = super.fetchFromGitHub {
        owner = "vim-scripts";
        repo = "gitignore.vim";
        rev = "3ad6a15768945fd4fc1b013cec5d8c8e62c7bb87";
        sha256 = "0fg36hrkwqb3accqm7ihw1cjs64fxf73zk06gickdkzq0zn4yl8x";
      };
    };

    vim-hybrid-material = super.vimUtils.buildVimPluginFrom2Nix {
      pname = "vim-hybrid-material";
      version = "2018-11-12";
      src = super.fetchFromGitHub {
        owner = "kristijanhusak";
        repo = "vim-hybrid-material";
        rev = "f2e92ac7e5c4bb75d72f0abaea939e4364e00e2e";
        sha256 = "01b9n598106qh68ky3fykczq13pldi221r7lrxvg0vnv2zp1z5qd";
      };
    };

    vim-tmux = super.vimUtils.buildVimPluginFrom2Nix {
      pname = "vim-tmux";
      version = "2019-03-22";
      src = super.fetchFromGitHub {
        owner = "tmux-plugins";
        repo = "vim-tmux";
        rev = "4e77341a2f8b9b7e41e81e9debbcecaea5987c85";
        sha256 = "16fgc0lx1jr8zbayanf5w677ssiw5xb8vwfaca295c8xlk760c3m";
      };
    };
  };
}
