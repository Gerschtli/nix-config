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

    flake-utils.url = "github:numtide/flake-utils";

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
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      flakeLib = import ./flake {
        inherit inputs;
        rootPath = ./.;
      };

      inherit (nixpkgs.lib) listToAttrs;
      inherit (flakeLib) mkHome mkNixOnDroid mkNixos eachSystem;
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
        (mkNixos "x86_64-linux" "krypton")
        (mkNixos "x86_64-linux" "neon")
        (mkNixos "aarch64-linux" "xenon")
      ];
    }
    // eachSystem ({ mkApp, mkCheck, mkDevShellJdk }: {
      apps = listToAttrs [
        (mkApp "format" {
          file = ./files/apps/format.sh;
          path = pkgs: with pkgs; [ nixpkgs-fmt statix ];
        })
        (mkApp "setup" {
          file = ./files/apps/setup.sh;
          path = pkgs: with pkgs; [ cachix coreutils curl git gnugrep hostname jq nix_2_4 openssh ];
          envs._doNotClearPath = true;
        })
      ];

      checks = listToAttrs [
        (mkCheck "nixpkgs-fmt" {
          script = pkgs: ''
            shopt -s globstar
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}/**/*.nix
          '';
        })

        # FIXME: use exit-code when https://github.com/nerdypepper/statix/issues/20 is resolved
        (mkCheck "statix" {
          script = pkgs: ''
            ${pkgs.statix}/bin/statix check ${./.} --format errfmt | tee output
            [[ "$(cat output)" == "" ]]
          '';
        })
      ];

      # use like:
      # $ direnv-init jdk11
      devShells = listToAttrs [
        (mkDevShellJdk "jdk8" { jdk = pkgs: pkgs.jdk8; })
        (mkDevShellJdk "jdk11" { jdk = pkgs: pkgs.jdk11; })
        (mkDevShellJdk "jdk15" { jdk = pkgs: pkgs.jdk15; })
        (mkDevShellJdk "jdk17" { jdk = pkgs: pkgs.jdk17_headless; })
      ];
    });
}
