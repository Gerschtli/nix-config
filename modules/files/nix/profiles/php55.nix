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

mkShell {
  name = "php55";

  buildInputs = [
    ant
    nodejs-10_x
    nur-gerschtli.php55
    nur-gerschtli.php55.packages.composer
    vagrant
  ] ++ (map (ext: nur-gerschtli.php55.packages.${ext}) extensions);

  APPLICATION_ENV = "development";

  PHPRC = import ./util/phpIni.nix {
    inherit extensions lib writeTextDir;
    phpPackage  = nur-gerschtli.php55;
    phpPackages = nur-gerschtli.php55.packages;
  };
}
