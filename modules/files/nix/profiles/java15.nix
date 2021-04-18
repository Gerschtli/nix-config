with import <nixpkgs> { };

mkShell {
  name = "java15";

  buildInputs = [
    nur-gerschtli.jdk15
    terraform
  ];

  JAVA_HOME = "${nur-gerschtli.jdk15}/lib/openjdk";
}
