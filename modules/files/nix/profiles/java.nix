with import <nixpkgs> { };

mkShell {
  name = "java";

  buildInputs = [
    nur-gerschtli.maven35
  ];
}
