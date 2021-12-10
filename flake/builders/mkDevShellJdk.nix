{ pkgs, name, args, ... }:

let
  jdk = args.jdk pkgs;
in

pkgs.mkShell {
  inherit name;
  buildInputs = [ jdk pkgs.maven ];
  JAVA_HOME = "${jdk}/lib/openjdk";
}
