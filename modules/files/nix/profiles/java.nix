with import <nixpkgs> { };

mkShell {
  name = "java";

  buildInputs = [
    jdk8
    nur-gerschtli.maven35
  ];

  JAVA_HOME = "${jdk8}/lib/openjdk";
}
