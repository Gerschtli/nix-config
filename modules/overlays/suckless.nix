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
      rev = "bd326150d4c2a67091ccec56e64b534b0b91e560";
      sha256 = "05yc7qvw6pmjisxp8cp1xrv8f9g3ni2bridggfbfrsaw5zwah2g2";
    };
  }
