with import <nixpkgs> { };

mkShell {
  name = "java17";

  buildInputs = [
    jdk17_headless
    maven
  ];

  JAVA_HOME = "${jdk17_headless}/lib/openjdk";
}
