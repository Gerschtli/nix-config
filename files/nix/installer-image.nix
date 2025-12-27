{ nixpkgs }:

let
  configuration =
    { config, lib, pkgs, modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix")
      ];

      environment.systemPackages = with pkgs; [
        git
        tmux
        vim
        wget
      ];

      hardware.enableAllFirmware = true;

      nixpkgs.config.allowUnfree = true;

      nix.settings = {
        substituters = [
          "https://cache.nixos.org"
          "https://gerschtli.cachix.org"
        ];
        trusted-public-keys = lib.mkForce [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
        ];
        experimental-features = [ "nix-command" "flakes" ];
      };

      time.timeZone = "Europe/Berlin";
    };

  evaluatedConfig = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [ configuration ];
  };
in

evaluatedConfig.config.system.build.isoImage
