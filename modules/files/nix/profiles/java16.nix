with import <nixpkgs> { };

mkShell {
  name = "java16";

  buildInputs = [
    jdk16
    terraform
  ];

  JAVA_HOME = "${jdk16}/lib/openjdk";
}
