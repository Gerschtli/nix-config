with import <nixpkgs> { };

mkShell {
  name = "python37";

  buildInputs = [
    pipenv
    python37
  ];

  LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib";
}
