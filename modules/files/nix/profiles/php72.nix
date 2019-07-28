# virtualbox must be installed globally by the default package manager

with import <nixpkgs> { };

let
  extensions = [
    "apcu" # needs to be before apcu_bc
    "apcu_bc"
    "igbinary" # needs to be before couchbase
    "couchbase"
    "memcached"
  ];

  php72_ = php72.overrideAttrs (old: {
    postInstall = old.postInstall + ''
      ln -snf $out/bin/php $out/bin/php72
    '';
  });
in

stdenv.mkDerivation {
  name = "php72";

  buildInputs = [
    nodejs-10_x
    php72_
    php72Packages.composer
    vagrant
  ] ++ (map (ext: php72Packages.${ext}) extensions);

  APPLICATION_ENV = "development";

  PHPRC = import ./util/phpIni.nix {
    inherit extensions lib writeTextDir;
    phpPackage  = php72_;
    phpPackages = php72Packages;
  };
}
