{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # commit before jdk15 drop
    # https://github.com/NixOS/nixpkgs/commit/9dde9d8b9ee4b7a4dfbb0ab1204d9f6f4a188360
    nixpkgs-for-jdk15.url = "github:NixOS/nixpkgs/df175b7f61d852dc599fe248b1a8666c312457bd";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # homeage.url = "github:jordanisaacs/homeage";
    homeage.url = "github:Gerschtli/homeage/support-script";

    dmenu.url = "github:Gerschtli/dmenu";
    dwm.url = "github:Gerschtli/dwm";
    dwm-status.url = "github:Gerschtli/dwm-status";
    teamspeak-update-notifier.url = "github:Gerschtli/teamspeak-update-notifier";

    # FIXME: use statix of nixpkgs when 0.4.2 is available
    statix = {
      url = "github:nerdypepper/statix/v0.4.2";
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
    , statix
    }:
    let
      rootPath = toString ./.;

      ## overlay config

      unstablePerSystem = system: import unstable {
        inherit system;
        config.allowUnfree = true;
      };

      overlay = nixpkgs.lib.composeManyExtensions [
        (final: prev: {
          inherit (agenix-cli.packages.${prev.system}) agenix;
          inherit (nixpkgs-for-jdk15.legacyPackages.${prev.system}) jdk15;

          inherit (unstablePerSystem prev.system)
            # need bleeding edge version
            jetbrains
            portfolio
            teamspeak_server
            ;

          gerschtli =
            prev.lib.composeManyExtensions
              [
                dmenu.overlay
                dwm.overlay
                dwm-status.overlay
                teamspeak-update-notifier.overlay
              ]
              final
              prev;
        })

        statix.overlay
      ];

      ## configure nixpkgs

      pkgsPerSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };

      ## builder helper

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

      forSystems = systems: builder:
        nixpkgs.lib.genAttrs
          systems
          (system:
            let
              pkgs = pkgsPerSystem system;
              customLib = customLibPerSystem system;
            in
            builder { inherit customLib pkgs system; }
          );

      forX86System = forSystems [ "x86_64-linux" ];
      foreachSystem = forSystems [ "aarch64-linux" "x86_64-linux" ];

      ## builder

      buildHome = system: hostName: username: home-manager.lib.homeManagerConfiguration {
        inherit username system;

        configuration = ./hosts + "/${hostName}/home-${username}.nix";
        homeDirectory = "/home/${username}";
        extraModules = homeModulesPerSystem system;
        extraSpecialArgs = { inherit rootPath; };
        pkgs = pkgsPerSystem system;
        stateVersion = "21.11";
      };

      # FIXME: pass in instance of pkgs when argument is added
      buildNixOnDroid = system: device: nix-on-droid.lib.${system}.nix-on-droid {
        config = import (./hosts + "/${device}/nix-on-droid.nix") {
          inherit rootPath;
          homeModules = homeModulesPerSystem system;
          pkgs = pkgsPerSystem system;
        };
      };

      buildNixosSystem = system: hostName: nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit rootPath;
          homeModules = homeModulesPerSystem system;
        };

        modules = [
          (./hosts + "/${hostName}/configuration.nix")
          (./hosts + "/${hostName}/hardware-configuration.nix")

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

      apps = foreachSystem ({ customLib, pkgs, ... }: {
        format = {
          type = "app";
          program = "${customLib.mkScriptPlain "format" ./files/apps/format.sh [ pkgs.nixpkgs-fmt pkgs.statix ] { }}";
        };
      });

      # FIXME: enable checks for all systems when statix can be build on aarch64-linux
      # checks = foreachSystem ({ pkgs, ... }:
      checks = forX86System ({ pkgs, ... }: {
        nixpkgs-fmt = pkgs.runCommand "nixpkgs-fmt-check" { } ''
          shopt -s globstar
          ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}/**/*.nix
          touch $out
        '';

        # FIXME: use exit-code when https://github.com/nerdypepper/statix/issues/20 is resolved
        statix = pkgs.runCommand "statix-check" { } ''
          ${pkgs.statix}/bin/statix check ${./.} --format errfmt | tee output
          [[ "$(cat output)" == "" ]]
          touch $out
        '';
      });

      # use like:
      # $ echo "use flake ~/.nix-config#jdk11" > .envrc
      # $ direnv allow .
      devShells = forX86System ({ pkgs, ... }:
        builtins.mapAttrs
          (name: jdk: pkgs.mkShell {
            inherit name;
            buildInputs = [ jdk pkgs.maven ];
            JAVA_HOME = "${jdk}/lib/openjdk";
          })
          {
            inherit (pkgs) jdk8 jdk11 jdk15;
            jdk17 = pkgs.jdk17_headless;
          }
      );
    };
}
