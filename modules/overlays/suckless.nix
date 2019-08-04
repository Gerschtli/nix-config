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
      rev = "c3e28890c0578c722ef48f823b0eb3e0710682d5";
      sha256 = "01bqn2b23yvx33hhjck1jghvpz4cq7nck3nq4h27l5farfr5krbc";
    };
  }
