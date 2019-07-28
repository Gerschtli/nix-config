# virtualbox must be installed globally by the default package manager

with import <nixpkgs> { };

let
  extensions = [
    "apcu"
    "igbinary" # needs to be before couchbase
    "couchbase"
    "memcache"
    "memcached"
  ];
in

stdenv.mkDerivation {
  name = "php55";

  buildInputs = [
    ant
    nodejs-10_x
    php55
    php55Packages.composer
    vagrant
  ] ++ (map (ext: php55Packages.${ext}) extensions);

  APPLICATION_ENV = "development";

  PHPRC = import ./util/phpIni.nix {
    inherit extensions lib writeTextDir;
    phpPackage  = php55;
    phpPackages = php55Packages;
  };
}
