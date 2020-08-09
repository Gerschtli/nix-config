self: super:

{
  # FIXME: remove when https://github.com/NixOS/nixpkgs/pull/94495 gets merged
  liquidprompt = super.liquidprompt.overrideAttrs (old: rec {
    pname = "liquidprompt";
    version = "1.12.0";

    src = super.fetchFromGitHub {
      owner = "nojhan";
      repo = pname;
      rev = "v${version}";
      sha256 = "0ibp1bz9s4bp3y5anivg5gp31q78024w39v7hbfw05qy25ax5h60";
    };
  });
}
