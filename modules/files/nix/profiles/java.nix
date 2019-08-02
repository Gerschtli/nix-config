with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "java";

  buildInputs = [
    maven35
  ];
}
