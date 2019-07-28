with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "integration-test";

  buildInputs = [
    nodejs-10_x
  ];
}
