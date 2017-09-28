# remove for future releases

self: super:

{
  slock = super.slock.overrideDerivation (old: {
    patchPhase = null;
    postPatch = old.patchPhase;
  });
}
