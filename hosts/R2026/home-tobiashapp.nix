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

  home.packages = with pkgs; [
    awscli2
    coreutils
    nixpkgs-fmt
    nodejs
  ];

  programs.zsh.initExtra = lib.mkAfter ''
    complete -C '${pkgs.awscli2}/bin/aws_completer' aws
    source <(kubectl completion zsh)
  '';
}
