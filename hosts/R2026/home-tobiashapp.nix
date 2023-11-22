{ config, lib, pkgs, ... }:

{
  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
    };

    development = {
      jbang = {
        enable = true;
        trustedSources = [ "https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/" ];
      };

      nix.nix-darwin.enable = true;
    };

    misc = {
      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk17;
        };
      };

      work = {
        enable = true;
        directory = "randstad";
        mailAddress = "tobias.happ@randstaddigital.com";
      };
    };
  };

  home.packages = with pkgs; [ nixpkgs-fmt nodejs ];
}
