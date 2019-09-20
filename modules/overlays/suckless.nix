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
      rev = "aca0f6de62b5a8bdd21b7ed856ff0421868b5284";
      sha256 = "05yc7qvw6pmjisxp8cp1xrv8f9g3ni2bridggfbfrsaw5zwah2g2";
    };
  }
