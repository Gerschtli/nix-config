{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.non-nixos.enable = true;

    development.nix.home-manager.enable = true;

    programs.ssh.modules = [ "private" ];
  };

  home = {
    homeDirectory = "/home/tobias";
    username = "tobias";
  };

  # FIXME: move to some module
  nixpkgs =  {
    config = import (config.lib.custom.path.files + "/config.nix");
    overlays = map import (config.lib.custom.getFileList config.lib.custom.path.overlays);
  };
}
