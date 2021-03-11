with import <nixpkgs> { };

mkShell {
  name = "java15";

  buildInputs = [
    jdk15
    terraform
  ];

  JAVA_HOME = "${jdk15}/lib/openjdk";
}
