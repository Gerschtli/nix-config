{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      general.darwin = true;

      desktop = {
        enable = true;
        laptop = true;
      };
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
          inherit (pkgs) jdk17 jdk21;
        };
      };

      work = {
        enable = true;
        directory = "randstad";
        mailAddress = "tobias.happ@randstaddigital.com";
      };
    };
  };

  home.packages = with pkgs; [
    coreutils
    kubectl
    nixpkgs-fmt
  ];

  programs.zsh.initExtra = lib.mkAfter ''
    source <(kubectl completion zsh)
  '';
}
