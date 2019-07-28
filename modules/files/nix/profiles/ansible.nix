with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "ansible";

  buildInputs = [
    ansible
  ];
}
