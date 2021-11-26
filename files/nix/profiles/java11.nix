with import <nixpkgs> { };

mkShell {
  name = "java11";

  buildInputs = [
    jdk11
    maven
  ];

  JAVA_HOME = "${jdk11}/lib/openjdk";
}
