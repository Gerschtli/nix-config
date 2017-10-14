{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.auto-golden-river-jazztett;

  fetchBitbucket = pkgs.callPackage ../../lib/fetch-bitbucket.nix { };

  autoGoldenRiverJazztett = pkgs.stdenv.mkDerivation rec {
    name = "auto-golden-river-jazztett-${version}";
    version = "2017-09-03";

    src = fetchBitbucket {
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

  ###### interface

  options = {

    custom.applications.auto-golden-river-jazztett = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install auto.goldenriverjazztett.de.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services = {
      httpd = {
        enable = true;
        virtualHosts = [
          {
            hostName = "auto.goldenriverjazztett.de";
            documentRoot = "${autoGoldenRiverJazztett}";
            php = true;
          }
        ];
      };

      mysql.enable = true;
    };

  };

}
