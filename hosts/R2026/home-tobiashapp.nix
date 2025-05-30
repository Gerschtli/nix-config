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

    development.nix.home-manager.enable = true;

    misc = {
      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk17 jdk21;
        };
      };

      work.randstad.directory = "randstad";
    };

    wm.yabai.enable = true;
  };

  home = {
    homeDirectory = "/Users/tobiashapp";
    username = "tobiashapp";

    packages = with pkgs; [
      awscli2
      nixpkgs-fmt
      nodejs_22
    ];
  };

  programs.zsh.initContent = lib.mkAfter ''
    complete -C '${pkgs.awscli2}/bin/aws_completer' aws
    source <(kubectl completion zsh)
  '';
}
