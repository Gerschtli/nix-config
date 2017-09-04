{ pkgs, config, ... }:

let

  fetchBitBucket = import ../util/fetchBitBucket.nix pkgs;

  autoGoldenRiverJazztett = pkgs.stdenv.mkDerivation rec {
    name = "auto-golden-river-jazztett-${version}";
    version = "2017-09-03";

    src = fetchBitBucket {
      url = "git@bitbucket.org:tobiashapp/auto-golden-river-jazztett.git";
      rev = "82025349769f8c011791c212168eddd822d942c8";
      sha256 = "0kvy60s1p3kxxk43i6pd4gka64plqd46dh2dfs24wmz57rhzh10s";
    };

    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

    installPhase = "cp -R . \$out";

    postFixup = ''
      rm $out/dump.sql $out/install.sh
    '';
  };

in

{
  imports = [
    ../services/httpd.nix
    ../services/mysql.nix
  ];

  services.httpd = {
    enablePHP = true;
    virtualHosts = [
      {
        hostName = "auto.goldenriverjazztett.de";
        documentRoot = "${autoGoldenRiverJazztett}";
        extraConfig = ''
          <Directory ${autoGoldenRiverJazztett}>
            Options -Indexes
            DirectoryIndex index.php
            AllowOverride All
          </Directory>
        '';
      }
    ];
  };
}
