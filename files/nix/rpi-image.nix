{ nixpkgs, rootPath }:

let
  configuration =
    { modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
      ];

      networking = {
        usePredictableInterfaceNames = false;

        wireless = {
          enable = true;
          interfaces = [ "wlan0" ];
        };
      };

      sdImage.compressImage = false;

      services.openssh.enable = true;

      system.stateVersion = "22.11";

      # needed because wpa_supplicant fails on startup
      # see https://github.com/NixOS/nixpkgs/issues/82462
      systemd.services.wpa_supplicant.serviceConfig = {
        Restart = "always";
        RestartSec = 5;
      };

      users.users.root = {
        password = "nixos";
        openssh.authorizedKeys.keyFiles = [ "${rootPath}/files/keys/id_rsa.tobias.pub" ];
      };
    };

  evaluatedConfig = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";

    modules = [ configuration ];
  };
in

evaluatedConfig.config.system.build.sdImage
