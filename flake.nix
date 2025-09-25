{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-formatter-pack.follows = "nix-formatter-pack";
      inputs.nmd.follows = "nix-formatter-pack/nmd";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeage = {
      url = "github:Gerschtli/homeage";
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

  outputs = { self, nixpkgs, nix-formatter-pack, ... } @ inputs:
    let
      rootPath = self;
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
      flakeLib = import ./flake {
        inherit inputs rootPath forEachSystem;
      };

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs system;
        checkFiles = [ self ];

        config.tools = {
          deadnix = {
            enable = true;
            noLambdaPatternNames = true;
          };
          nixpkgs-fmt.enable = true;
          statix = {
            enable = true;
            disabledLints = [ "repeated_keys" ];
          };
        };
      });

      inherit (nixpkgs.lib) listToAttrs;
      inherit (flakeLib) mkApp mkDevShellJdk mkDevShellPhp mkHome mkNixOnDroid mkNixos;
    in
    {
      homeConfigurations = listToAttrs [
        (mkHome "x86_64-linux" "tobias@gamer")
        (mkHome "aarch64-darwin" "tobiashapp@bwpm-FP2CYXKY2V")
        (mkHome "aarch64-darwin" "tobiashapp@R2026")
      ];

      nixOnDroidConfigurations = listToAttrs [
        (mkNixOnDroid "aarch64-linux" "pixel9")
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
        (mkDevShellJdk system "jdk21" { jdk = pkgs: pkgs.jdk21; })

        (mkDevShellPhp system "php82" { phpVersion = "82"; })
      ]);

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});

      nixosModules.nixos-shell-vm = import ./files/nix/nixos-shell-vm.nix rootPath;

      packages =
        let
          cachixSpecBuilder = pkgs: spec: pkgs.writeText "cachix-deploy.json" (builtins.toJSON spec);

          cachixDeployOutput = builder: name: module: {
            ${module.pkgs.system}."cachix-deploy-spec-${name}" = cachixSpecBuilder module.pkgs {
              agents.${name} = builder module;
            };
          };

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
          (nixpkgs.lib.mapAttrsToList cachixDeployOutputNixos self.nixosConfigurations);
    };
}
