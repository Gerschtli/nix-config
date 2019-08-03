{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.nodejs;

  # TODO: add in nixpkgs
  zsh-better-npm-completion = pkgs.stdenv.mkDerivation {
    name = "zsh-better-npm-completion";

    src = pkgs.fetchFromGitHub {
      owner = "lukechilds";
      repo = "zsh-better-npm-completion";
      rev = "b61f6bb4e640728c42ae84ca55a575ee88c60fe8";
      sha256 = "00c1gdsam0z6v09fvz7hyl0zgmgnwbf59i1yrbkrz08frjlr16ax";
    };

    installPhase = ''
      mkdir -p $out/share/zsh-better-npm-completion

      install -m 0644 zsh-better-npm-completion.plugin.zsh $out/share/zsh-better-npm-completion
    '';
  };
in

{

  ###### interface

  options = {

    custom.development.nodejs.enable = mkEnableOption "nodejs config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.file.".npmrc".text = ''
      engine-strict=true
    '';

    programs = {
      bash.initExtra = ''
        if available npm; then
          eval "$(npm completion)"
        fi
      '';

      zsh.plugins = [
        {
          name = "zsh-better-npm-completion";
          src = "${zsh-better-npm-completion}/share/zsh-better-npm-completion";
        }
      ];
    };

  };

}
