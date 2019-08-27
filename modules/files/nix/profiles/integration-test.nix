with import <nixpkgs> { };

mkShell {
  name = "integration-test";

  buildInputs = [
    nodejs-10_x
  ];
}
