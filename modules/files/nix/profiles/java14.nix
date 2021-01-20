with import <nixpkgs> { };

mkShell {
  name = "java14";

  buildInputs = [
    jdk14
    terraform
  ];

  JAVA_HOME = "${jdk14}/lib/openjdk";
}
