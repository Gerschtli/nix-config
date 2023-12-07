{ nixpkgs }:

let
  configuration =
    { config, pkgs, modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
      ];

      system = {
        build.firmware = pkgs.runCommand "firmware" { } ''
          mkdir firmware ${placeholder "out"}

          ${config.sdImage.populateFirmwareCommands}

          cp -r firmware/* ${placeholder "out"}
        '';

        stateVersion = "23.11";
      };
    };

  evaluatedConfig = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";

    modules = [ configuration ];
  };
in

evaluatedConfig.config.system.build.firmware
