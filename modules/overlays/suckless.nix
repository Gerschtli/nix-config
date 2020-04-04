self: super:

builtins.mapAttrs
  (name: src:
    super.${name}.overrideDerivation (old: {
      patches = [ "${src}/patch-${super.lib.getVersion old}.diff" ];
    })
  )
  {
    dmenu = super.fetchFromGitHub {
      owner = "Gerschtli";
      repo = "dmenu";
      rev = "bc5406165327d05d53bf34836637d6ebc5fe2e9b";
      sha256 = "0q1z78mnca1lfwhp7cp3xlxlknhkzn4a2d63ahggazc1szaxrq80";
    };

    dwm = super.fetchFromGitHub {
      owner = "Gerschtli";
      repo = "dwm";
      rev = "2e9df187b41ca5d9ed320ed34f5215fb5b6bfebf";
      sha256 = "0dhgg5qj85nxy6cz4im3ndpcn5gv0v5zkzv2pid18gknnm4cdhah";
    };
  }
