with import <nixpkgs> { };

mkShell {
  name = "java";

  buildInputs = [
    maven35
  ];
}
