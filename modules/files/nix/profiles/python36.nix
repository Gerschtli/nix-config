with import <nixpkgs> { };

mkShell {
  name = "python36";

  buildInputs = [
    pipenv
    python36
  ];

  LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib";
}
