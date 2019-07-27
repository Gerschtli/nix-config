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
      rev = "7742a5146b28e4222cff78a20754f88235d46ad1";
      sha256 = "0q1z78mnca1lfwhp7cp3xlxlknhkzn4a2d63ahggazc1szaxrq80";
    };

    dwm = super.fetchFromGitHub {
      owner = "Gerschtli";
      repo = "dwm";
      rev = "692e5fe38f841bd37f3502820ebb66ec16b86590";
      sha256 = "0slcg3jgk1ksxrg1pbfgjyf03jb2dcsrc6aw2zwcy1ig1drqpbb4";
    };
  }
