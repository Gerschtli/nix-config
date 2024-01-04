{ system, pkgsFor, name, args, ... }:

let
  pkgs = pkgsFor.${system};
  jdk = args.jdk pkgs;
in

pkgs.mkShell {
  inherit name;
  buildInputs = [ jdk pkgs.maven ];
  JAVA_HOME = jdk;
}
