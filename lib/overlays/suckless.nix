self: super:

super.lib.genAttrs
  [ "dmenu" "dwm" "slock" ]
  (name: super.${name}.overrideDerivation (old: {
    patches = [ (../../patches + "/${name}-config.diff") ];
  }))
