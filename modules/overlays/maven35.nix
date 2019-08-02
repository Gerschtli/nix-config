self: super:

{
  maven35 = super.maven.overrideDerivation (old: rec {
    name = "apache-maven-${version}";
    version = "3.5.4";

    src = super.fetchurl {
      url = "mirror://apache/maven/maven-3/${version}/binaries/${name}-bin.tar.gz";
      sha256 = "0kd1jzlz3b2kglppi85h7286vdwjdmm7avvpwgppgjv42g4v2l6f";
    };
  });
}
