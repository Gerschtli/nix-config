{ system, pkgsFor, name, args, ... }:

let
  pkgs = pkgsFor.${system};
  version = args.phpVersion;

  phpPackage = pkgs."php${version}";
  phpExtensions = pkgs."php${version}Extensions";
  phpPackages = pkgs."php${version}Packages";

  extensions = [
    "bz2"
  ];
in

pkgs.mkShell {
  inherit name;

  buildInputs = [
    phpPackage
    phpPackages.composer
  ];

  PHPRC = import ./util/phpIni.nix {
    inherit (pkgs) lib writeTextDir;
    inherit extensions phpPackage phpExtensions;
  };
}
