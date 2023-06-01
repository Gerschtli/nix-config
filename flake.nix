{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # some commit containing mysql57 and php74
    nixpkgs-22-05.url = "github:NixOS/nixpkgs/695b3515251873e0a7e2021add4bba643c56cde3";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-formatter-pack.follows = "nix-formatter-pack";
      inputs.nmd.follows = "nix-formatter-pack/nmd";
    };

    cachix-deploy-flake = {
      url = "github:cachix/cachix-deploy-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = "cachix-deploy-flake/darwin";
    };
    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeage = {
      url = "github:jordanisaacs/homeage";
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

    nix-formatter-pack = {
      url = "github:Gerschtli/nix-formatter-pack";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixGL = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "agenix-cli/flake-utils";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, cachix-deploy-flake, nix-formatter-pack, ... } @ inputs:
    let
      rootPath = self;
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
      flakeLib = import ./flake {
        inherit inputs rootPath forEachSystem;
      };

      cachixDeployLibFor = forEachSystem (system: cachix-deploy-flake.lib nixpkgs.legacyPackages.${system});

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs system;
        checkFiles = [ self ];

        config.tools = {
          deadnix = {
            enable = true;
            noLambdaPatternNames = true;
          };
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      });

      inherit (nixpkgs.lib) listToAttrs;
      inherit (flakeLib) mkApp mkDevShellJdk mkDevShellPhp mkHome mkNixOnDroid mkNixos;
    in
    {
      homeConfigurations = listToAttrs [
        (mkHome "x86_64-linux" "tobias@gamer")
        (mkHome "x86_64-linux" "tobhap@M386")
      ];

      nixOnDroidConfigurations = listToAttrs [
        (mkNixOnDroid "aarch64-linux" "oneplus5")
      ];

      nixosConfigurations = listToAttrs [
        (mkNixos "aarch64-linux" "argon")
        (mkNixos "x86_64-linux" "krypton")
        (mkNixos "x86_64-linux" "neon")
        (mkNixos "aarch64-linux" "xenon")
      ];

      apps = forEachSystem (system: listToAttrs [
        (mkApp system "nixos-shell" {
          file = ./files/apps/nixos-shell.sh;
          path = pkgs: with pkgs; [ nixos-shell gawk jq git ];
        })

        (mkApp system "setup" {
          file = ./files/apps/setup.sh;
          path = pkgs: with pkgs; [ coreutils curl git gnugrep hostname jq nix openssh ];
          envs._doNotClearPath = true;
        })
      ]);

      checks = forEachSystem (system: {
        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsFor.${system};
      });

      # use like:
      # $ direnv-init jdk11
      # $ lorri-init jdk11
      devShells = forEachSystem (system: listToAttrs [
        (mkDevShellJdk system "jdk8" { jdk = pkgs: pkgs.jdk8; })
        (mkDevShellJdk system "jdk11" { jdk = pkgs: pkgs.jdk11; })
        (mkDevShellJdk system "jdk17" { jdk = pkgs: pkgs.jdk17-0-7; })

        (mkDevShellPhp system "php74" { phpVersion = "74"; })
        (mkDevShellPhp system "php74-composer1" { phpVersion = "74"; composer1 = true; })
        (mkDevShellPhp system "php80" { phpVersion = "80"; })
        (mkDevShellPhp system "php81" { phpVersion = "81"; })
      ]);

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});

      nixosModules.nixos-shell-vm = import ./files/nix/nixos-shell-vm.nix rootPath;

      packages =
        let
          cachixDeployOutput = builder: name: module:
            let
              inherit (module.pkgs) system;
            in
            {
              ${system}."cachix-deploy-spec-${name}" = cachixDeployLibFor.${system}.spec {
                agents.${name} = builder module;
              };
            };

          cachixDeployOutputHomeManager = cachixDeployOutput (module: module.activationPackage);
          cachixDeployOutputNixos = cachixDeployOutput (module: module.config.system.build.toplevel);
        in
        nixpkgs.lib.foldl
          nixpkgs.lib.recursiveUpdate
          {
            aarch64-linux = {
              rpi-firmware = import ./files/nix/rpi-firmware.nix { inherit nixpkgs; };
              rpi-image = import ./files/nix/rpi-image.nix { inherit nixpkgs rootPath; };
            };

            x86_64-linux.installer-image = import ./files/nix/installer-image.nix { inherit nixpkgs; };
          }
          (nixpkgs.lib.mapAttrsToList cachixDeployOutputNixos self.nixosConfigurations
            ++ [ (cachixDeployOutputHomeManager "M386" self.homeConfigurations."tobhap@M386") ]);
    };
}
