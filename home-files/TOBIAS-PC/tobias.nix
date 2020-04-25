{ config, pkgs, ... } @ args:

{
  imports = [ ../../modules ];

  custom = {
    base.non-nixos.enable = true;

    programs.ssh.modules = [ "private" ];
  };

  # FIXME: move to some module
  nixpkgs =  {
    config = import ../../modules/files/config.nix;
    overlays =
      let
        customLib = import ../../modules/lib args;
        overlays = customLib.getFileList ../../modules/overlays;
      in
        map import overlays;
  };
}
