with import <nixpkgs> { };

mkShell {
  name = "java14";

  buildInputs = [
    nur-gerschtli.jdk14
    terraform
  ];

  JAVA_HOME = "${nur-gerschtli.jdk14}/lib/openjdk";
}
