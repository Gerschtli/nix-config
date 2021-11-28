{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # commit before jdk15 drop
    # https://github.com/NixOS/nixpkgs/commit/9dde9d8b9ee4b7a4dfbb0ab1204d9f6f4a188360
    nixpkgs-for-jdk15.url = "github:NixOS/nixpkgs/df175b7f61d852dc599fe248b1a8666c312457bd";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeage = {
      # url = "github:jordanisaacs/homeage";
      url = "github:Gerschtli/homeage/support-script";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dmenu = {
      url = "github:Gerschtli/dmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwm = {
      url = "github:Gerschtli/dwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwm-status = {
      url = "github:Gerschtli/dwm-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    teamspeak-update-notifier = {
      url = "github:Gerschtli/teamspeak-update-notifier";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , unstable
    , nixpkgs-for-jdk15
    , home-manager
    , nix-on-droid
    , agenix
    , agenix-cli
    , homeage
    , dmenu
    , dwm
    , dwm-status
    , teamspeak-update-notifier
    }:
    let
      pkgsPerSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };

      unstablePerSystem = system: import unstable {
        inherit system;
        config.allowUnfree = true;
      };

      overlay = final: prev: {
        inherit (nixpkgs-for-jdk15.legacyPackages.${prev.system}) jdk15;

        inherit (unstablePerSystem prev.system)
          # need bleeding edge version
          jetbrains
          portfolio
          teamspeak_server

          # TODO: remove as soon as available in stable
          jdk17_headless
          ventoy-bin
          ;

        agenix = agenix-cli.packages.${prev.system}.agenix;

        gerschtli =
          prev.lib.foldr (a: b: a // b) { } (
            map (flake: flake.overlay final prev) [
              dmenu
              dwm
              dwm-status
              teamspeak-update-notifier
            ]);
      };

      customLibPerSystem = system: import ./lib {
        inherit (nixpkgs) lib;
        pkgs = pkgsPerSystem system;
      };

      homeModulesPerSystem = system:
        ((customLibPerSystem system).getRecursiveNixFileList ./home)
        ++ [
          homeage.homeManagerModules.homeage

          { lib.custom = customLibPerSystem system; }
        ];

      buildHome = system: hostName: username: home-manager.lib.homeManagerConfiguration {
        inherit username system;

        configuration = ./hosts/${hostName}/home-${username}.nix;
        homeDirectory = "/home/${username}";
        extraModules = homeModulesPerSystem system;
        extraSpecialArgs.rootPath = ./.;
        pkgs = pkgsPerSystem system;
        stateVersion = "21.05";
      };

      buildNixOnDroid = system: device: nix-on-droid.lib.${system}.nix-on-droid {
        config = import (./hosts + "/${device}/nix-on-droid.nix") {
          homeModules = homeModulesPerSystem system;
          rootPath = ./.;
        };
      };

      buildNixosSystem = system: hostName: nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          homeModules = homeModulesPerSystem system;
          rootPath = ./.;
        };

        modules = [
          ./hosts/${hostName}/configuration.nix
          ./hosts/${hostName}/hardware-configuration.nix

          agenix.nixosModules.age
          home-manager.nixosModules.home-manager

          {
            custom.base.general = { inherit hostName; };

            lib.custom = customLibPerSystem system;

            nixpkgs.pkgs = pkgsPerSystem system;

            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ]
        ++ (customLibPerSystem system).getRecursiveNixFileList ./nixos;
      };
    in
    {
      inherit overlay;

      homeConfigurations = {
        "tobias@gamer" = buildHome "x86_64-linux" "gamer" "tobias";
        "tobhap@M386" = buildHome "x86_64-linux" "M386" "tobhap";
      };

      nixOnDroidConfigurations = {
        oneplus5 = buildNixOnDroid "aarch64-linux" "oneplus5";
      };

      nixosConfigurations = {
        krypton = buildNixosSystem "x86_64-linux" "krypton";
        neon = buildNixosSystem "x86_64-linux" "neon";
        xenon = buildNixosSystem "aarch64-linux" "xenon";
      };
    };
}
