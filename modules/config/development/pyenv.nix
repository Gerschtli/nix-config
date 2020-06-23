{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.pyenv;

  # TODO: add in nixpkgs
  pyenv = pkgs.stdenv.mkDerivation {
    name = "pyenv";

    src = pkgs.fetchFromGitHub {
      owner = "pyenv";
      repo = "pyenv";
      rev = "5a96d9f2cd8b068a0be1baca9c7c77386f03d047";
      sha256 = "10c1gdsam0z6v09fvz7hyl0zgmgnwbf59i1yrbkrz08frjlr16ax";
    };

    installPhase = ''
      mkdir -p $out/share/zsh-better-npm-completion

      install -m 0644 zsh-better-npm-completion.plugin.zsh $out/share/zsh-better-npm-completion
    '';
  };

  pyenvRoot = "${config.home.homeDirectory}/.pyenv";
in

{

  ###### interface

  options = {

    custom.development.pyenv.enable = mkEnableOption "pyenv config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      base.general.extendedPath = [ "${pyenvRoot}/bin" ];

      programs.shell.initExtra = ''
        available pyenv && eval "$(pyenv init -)"
      '';
    };

    home.sessionVariables = {
      PYENV_ROOT = pyenvRoot;
    };

  };

}
