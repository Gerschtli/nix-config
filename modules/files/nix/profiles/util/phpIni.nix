# originally taken from https://gist.github.com/3noch/79255f8c5ec3c287b91b7484265a89a8

{ lib, writeTextDir, phpPackage, phpPackages, extensions ? [], enableXdebug ? false }:

let

  inherit (builtins) readFile;
  inherit (lib) concatMapStringsSep optionalString;
  inherit (lib.versions) majorMinor;

  includePackage = directive: packageName:
    let
      soName = if packageName == "apcu_bc" then "apc" else packageName;
    in
      "${directive} = ${phpPackages.${packageName}}/lib/php/extensions/${soName}.so";

  defaultPhpIni = readFile "${phpPackage}/etc/php.ini";

  phpIni = ''
    ${defaultPhpIni}

    ${optionalString (majorMinor phpPackage.version == "5.5") ''
      ; WARNING: Be sure to load opcache *before* xdebug (http://us3.php.net/manual/en/opcache.installation.php).
      zend_extension = "${phpPackage}/lib/php/extensions/opcache.so"
    ''}

    ${optionalString enableXdebug ''
      zend_extension = "${phpPackages.xdebug}/lib/php/extensions/xdebug.so"
    ''}

    ${concatMapStringsSep "\n" (includePackage "extension") (extensions)}

    error_reporting = E_ALL
    display_errors  = On

    memory_limit = 2G

    date.timezone = "Europe/Berlin"
  '';

in

writeTextDir "php.ini" phpIni
