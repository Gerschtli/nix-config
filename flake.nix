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

    nixinate = {
      url = "github:matthewcroughan/nixinate";
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

  outputs = { self, nixpkgs, nixinate, nix-formatter-pack, ... } @ inputs:
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
          (mkApp system "format" {
            file = ./files/apps/format.sh;
            path = pkgs: with pkgs; [ nixpkgs-fmt statix ];
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

      packages = forEachSystem (_: {
        rpi-firmware = import ./files/nix/rpi-firmware.nix { inherit nixpkgs; };
        rpi-image = import ./files/nix/rpi-image.nix { inherit nixpkgs rootPath; };
      });
    };
}
