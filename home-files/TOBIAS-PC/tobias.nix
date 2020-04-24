{ config, pkgs, ... } @ args:

{
  imports = [ ../../modules ];

  custom = {
    base.non-nixos.enable = true;

    programs.ssh.modules = [ "private" ];
  };

  # FIXME: move to some module
  nixpkgs =  {
    config = import ../../modules/config/files/config.nix;
    overlays =
      let
        customLib = import ../../modules/config/lib args;
        overlays = customLib.getFileList ../../modules/config/overlays;
      in
        map import overlays;
  };
}
