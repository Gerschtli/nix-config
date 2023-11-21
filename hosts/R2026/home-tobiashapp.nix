{ config, lib, pkgs, ... }:

{
  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
    };
    #    base.non-nixos.enable = true;

    development = {
      jbang = {
        enable = true;
        trustedSources = [ "https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/" ];
      };

      #nix.nixos.enable = true;
    };

    misc = {
      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk17 python310;
        };
      };

      work = {
        enable = true;
        directory = "randstad";
        mailAddress = "tobias.happ@randstaddigital.com";
      };
    };

    programs = {
      #go.enable = true;

      #vscode.enable = true;
    };
  };

  home.packages = with pkgs; [ nixpkgs-fmt nodejs ];
}
