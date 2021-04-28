with import <nixpkgs> { };

mkShell {
  name = "python38";

  buildInputs = [
    pipenv
    python38
  ];

  LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib";
}
