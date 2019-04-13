{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.dev;
in

{

  ###### interface

  options = {

    custom.misc.dev = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable dev packages/services.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    nixpkgs.config.allowUnfree = true;

    programs = {
      bash.interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook bash)"
      '';

      zsh.interactiveShellInit = ''
        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';
    };

    users.users.tobias = {
      extraGroups = [
        # "docker"
        "vboxusers"
      ];

      packages = with pkgs; [
        direnv
        postman
      ];
    };

    virtualisation = {
      # docker.enable = true;

      virtualbox.host.enable = true;
    };

  };

}
