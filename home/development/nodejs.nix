{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.nodejs;

  # FIXME: replace when https://github.com/NixOS/nixpkgs/pull/144611 is merged
  zsh-better-npm-completion = pkgs.stdenv.mkDerivation {
    name = "zsh-better-npm-completion";

    src = pkgs.fetchFromGitHub {
      owner = "lukechilds";
      repo = "zsh-better-npm-completion";
      rev = "0a7cf042415324ec38a186fdcbc9af163f0d7e69";
      sha256 = "sha256:16z7k5n1rcl9i61lrm7i5dsqsmhvdp1y4y5ii6hv2xpp470addgy";
    };

    installPhase = ''
      mkdir -p ${placeholder "out"}/share/zsh-better-npm-completion

      install -m 0644 zsh-better-npm-completion.plugin.zsh ${placeholder "out"}/share/zsh-better-npm-completion
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

    custom.programs.shell.dynamicShellInit = [
      {
        condition = "available npm && is_bash";

        initExtra = ''
          eval "$(npm completion)"
        '';
      }
    ];

    home.file.".npmrc".text = ''
      engine-strict=true
    '';

    programs.zsh.plugins = [
      {
        name = "zsh-better-npm-completion";
        src = "${zsh-better-npm-completion}/share/zsh-better-npm-completion";
      }
    ];

  };

}
