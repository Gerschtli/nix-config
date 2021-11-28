with import <nixpkgs> { };

mkShell {
  name = "java8";

  buildInputs = [
    jdk8
    maven
  ];

  JAVA_HOME = "${jdk8}/lib/openjdk";
}
