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

  composer =
    if args ? composer1 && args.composer1
    then
      phpPackages.composer.overrideAttrs
        (_old: rec {
          version = "1.10.26";
          src = pkgs.fetchurl {
            url = "https://github.com/composer/composer/releases/download/${version}/composer.phar";
            sha256 = "sha256-y/4fhSdsV6vkZNk0UD2TWqITSUrChidcjfq/qR49vcQ=";
          };
        })
    else phpPackages.composer;
in

pkgs.mkShell {
  inherit name;

  buildInputs = [
    composer
    phpPackage
  ];

  PHPRC = import ./util/phpIni.nix {
    inherit (pkgs) lib writeTextDir;
    inherit extensions phpPackage phpExtensions;
  };
}
