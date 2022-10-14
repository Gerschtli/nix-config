# originally taken from https://gist.github.com/3noch/79255f8c5ec3c287b91b7484265a89a8

{ lib, writeTextDir, phpPackage, phpExtensions, extensions ? [ ], enableXdebug ? false }:

let
  inherit (lib) concatMapStringsSep optionalString;

  includePackage = directive: extensionName: "${directive} = ${phpExtensions.${extensionName}}/lib/php/extensions/${extensionName}.so";

  # defaultPhpIni = readFile "${phpPackage}/etc/php.ini";

  phpIni = ''
    # FIXME: add defaultPhpIni here

    ${optionalString enableXdebug ''
      zend_extension = "${phpExtensions.xdebug}/lib/php/extensions/xdebug.so"
    ''}

    ${concatMapStringsSep "\n" (includePackage "extension") extensions}

    error_reporting = E_ALL
    display_errors  = On

    memory_limit = 2G

    date.timezone = "Europe/Berlin"
  '';

in

writeTextDir "php.ini" phpIni
