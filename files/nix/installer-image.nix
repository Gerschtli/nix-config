{ nixpkgs }:

let
  configuration =
    { config, lib, pkgs, modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix")
        (modulesPath + "/installer/cd-dvd/channel.nix")
      ];

      # taken from installation-cd-minimal-new-kernel-no-zfs.nix
      nixpkgs.overlays = [
        (final: super: {
          zfs = super.zfs.overrideAttrs (_: {
            meta.platforms = [ ];
          });
        })
      ];

      console.keyMap = "de";

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
