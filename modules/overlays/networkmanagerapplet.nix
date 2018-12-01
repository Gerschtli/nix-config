self: super:

{
  networkmanagerapplet = super.networkmanagerapplet.overrideDerivation (old: {
    buildInputs = old.buildInputs ++ [ self.hicolor-icon-theme ];
  });
}
