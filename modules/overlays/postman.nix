self: super:

{
  postman = super.postman.overrideDerivation (old: rec {
    name = "postman-${version}";
    version = "7.0.7";

    src = super.fetchurl {
      url = "https://dl.pstmn.io/download/version/${version}/linux64";
      sha256 = "47be1b955759520f3a2c7dcdecb85b4c52c38df717da294ba184f46f2058014a";
      name = "${name}.tar.gz";
    };
  });
}
