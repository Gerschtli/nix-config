with import <nixpkgs> { };

mkShell {
  name = "java15";

  buildInputs = [
    nur-gerschtli.jdk15
    maven
  ];

  JAVA_HOME = "${nur-gerschtli.jdk15}/lib/openjdk";
}
