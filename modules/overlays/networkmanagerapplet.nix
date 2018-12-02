# FIXME: remove when https://github.com/NixOS/nixpkgs/commit/49be1fad9b737b201e7cbebb3221d0e3b081c3af gets merged

self: super:

{
  networkmanagerapplet = super.networkmanagerapplet.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [ self.gnome3.defaultIconTheme ];
  });
}
