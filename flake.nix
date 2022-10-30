{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # commit before jdk15 drop
    # https://github.com/NixOS/nixpkgs/commit/9dde9d8b9ee4b7a4dfbb0ab1204d9f6f4a188360
    nixpkgs-for-jdk15.url = "github:NixOS/nixpkgs/df175b7f61d852dc599fe248b1a8666c312457bd";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cachix-deploy-flake.url = "github:cachix/cachix-deploy-flake";
    nixinate = {
      # FIXME: pin until https://github.com/MatthewCroughan/nixinate/pull/30#issuecomment-1293550407 is resolved
      url = "github:matthewcroughan/nixinate/bc620b8f801f4d0dcb2a1fb6d061fff0d585d4a5";
      inputs.nixpkgs.follows = "nixpkgs";
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
    };
  };

  outputs = { self, nixpkgs, cachix-deploy-flake, nixinate, nix-formatter-pack, ... } @ inputs:
    let
      rootPath = toString ./.;
      forEachSystem = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
      flakeLib = import ./flake {
        inherit inputs rootPath forEachSystem;
      };

      formatterPackArgsFor = forEachSystem (system: {
        inherit nixpkgs system;
        checkFiles = [ ./. ];

        config.tools = {
          deadnix = {
            enable = true;
            noLambdaPatternNames = true;
          };
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      });

      inherit (nixpkgs.lib) listToAttrs mapAttrs' nameValuePair;
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

      apps = forEachSystem (system: (
        listToAttrs [
          (mkApp system "ci-build" {
            file = ./files/apps/ci-build.sh;
            path = pkgs: with pkgs; [ nix nix-build-uncached ];
            envs = { inherit rootPath; };
          })
          (mkApp system "setup" {
            file = ./files/apps/setup.sh;
            path = pkgs: with pkgs; [ cachix coreutils curl git gnugrep hostname jq nix openssh ];
            envs._doNotClearPath = true;
          })
        ]
      ) // (
        mapAttrs'
          (name: nameValuePair ("nixinate-" + name))
          (nixinate.nixinate.${system} self).nixinate
      ));

      checks = forEachSystem (system: {
        nix-formatter-pack-check = nix-formatter-pack.lib.mkCheck formatterPackArgsFor.${system};
      });

      # use like:
      # $ direnv-init jdk11
      # $ lorri-init jdk11
      devShells = forEachSystem (system: listToAttrs [
        (mkDevShellJdk system "jdk8" { jdk = pkgs: pkgs.jdk8; })
        (mkDevShellJdk system "jdk11" { jdk = pkgs: pkgs.jdk11; })
        (mkDevShellJdk system "jdk15" { jdk = pkgs: pkgs.jdk15; })
        (mkDevShellJdk system "jdk17" { jdk = pkgs: pkgs.jdk17; })

        (mkDevShellPhp system "php74" { phpVersion = "74"; })
        (mkDevShellPhp system "php80" { phpVersion = "80"; })
        (mkDevShellPhp system "php81" { phpVersion = "81"; })
      ]);

      formatter = forEachSystem (system: nix-formatter-pack.lib.mkFormatter formatterPackArgsFor.${system});

      packages = forEachSystem (system: {
        cachix-deploy-spec =
          let
            cachix-deploy-lib = cachix-deploy-flake.lib nixpkgs.legacyPackages.${system};
          in
          cachix-deploy-lib.spec {
            agents = {
              argon = self.nixosConfigurations.argon.config.system.build.toplevel;
              neon = self.nixosConfigurations.neon.config.system.build.toplevel;
            };
          };

        rpi-firmware = import ./files/nix/rpi-firmware.nix { inherit nixpkgs; };
        rpi-image = import ./files/nix/rpi-image.nix { inherit nixpkgs rootPath; };
      });
    };
}
