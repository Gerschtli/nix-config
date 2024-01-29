{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      general.darwin = true;

      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development = {
      jbang = {
        enable = true;
        trustedSources = [ "https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/" ];
      };

      nix.home-manager.enable = true;
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

    wm.yabai.enable = true;
  };

  home = {
    homeDirectory = "/Users/tobiashapp";
    username = "tobiashapp";

    packages = with pkgs; [
      awscli2
      nixpkgs-fmt
      nodejs
    ];
  };

  programs.zsh.initExtra = lib.mkAfter ''
    complete -C '${pkgs.awscli2}/bin/aws_completer' aws
    source <(kubectl completion zsh)
  '';
}
