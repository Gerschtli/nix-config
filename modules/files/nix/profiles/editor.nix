with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "editor";

  buildInputs = [
    nodejs-10_x
    php
    phpPackages.composer
  ];

  PHPRC = import ./util/phpIni.nix {
    inherit lib writeTextDir;
    phpPackage   = php;
    phpPackages  = phpPackages;
    enableXdebug = true;
  };
}
