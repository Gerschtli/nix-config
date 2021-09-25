{ config, pkgs, ... }:

{
  imports = [ (import ./modules "argon") ];

  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
    };

    ids.enable = true;

    programs = {
      arduino.enable = true;

      docker.enable = true;
    };
  };

  nix = {
    package = pkgs.nixFlakes;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
