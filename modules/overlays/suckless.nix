self: super:

super.lib.genAttrs
  [ "dmenu" "dwm" ]
  (name:
    let
      json = builtins.fromJSON (builtins.readFile (./suckless + "/${name}.json"));

      src = super.fetchFromGitHub {
        inherit (json) rev sha256;

        owner = "Gerschtli";
        repo = name;
      };
    in
      super.${name}.overrideDerivation (old: {
        patches = [
          "${src}/patch-${super.lib.getVersion old}.diff"
        ];
      })
  )
