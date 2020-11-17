with import <nixpkgs> { };

mkShell {
  name = "java11";

  buildInputs = [
    jdk11
    terraform
  ];

  JAVA_HOME = "${jdk11}/lib/openjdk";
}
