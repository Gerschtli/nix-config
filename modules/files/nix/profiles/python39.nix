with import <nixpkgs> { };

mkShell {
  name = "python39";

  buildInputs = [
    pipenv
    python39
  ];

  LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib";
}
