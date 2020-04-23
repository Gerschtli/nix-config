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
in

mkShell {
  name = "php72";

  buildInputs = [
    nodejs-10_x
    nur-gerschtli.php72-symlink
    php72Packages.composer
    vagrant
  ] ++ (map (ext: php72Packages.${ext}) extensions);

  APPLICATION_ENV = "development";

  PHPRC = import ./util/phpIni.nix {
    inherit extensions lib writeTextDir;
    phpPackage  = nur-gerschtli.php72-symlink;
    phpPackages = php72Packages;
  };
}
