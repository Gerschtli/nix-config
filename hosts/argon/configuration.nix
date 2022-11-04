{ config, lib, pkgs, rootPath, ... }:

{
  custom = {
    applications.original-chattengauer.enable = true;

    base.server.enable = true;

    cachix-agent.enable = true;

    services = {
      backup.enable = true;

      minecraft-server.enable = true;

      openssh.enable = true;
    };

    system.boot.mode = "efi";
  };

  home-manager.users.steini = import "${rootPath}/hosts/${config.custom.base.general.hostname}/home-steini.nix";

  security.sudo.extraRules = [
    {
      users = [ "steini" ];
      runAs = "root:root";
      commands = map
        (command: {
          command = "/run/current-system/sw/bin/${command}";
          options = [ "NOPASSWD" ];
        })
        [
          "journalctl -xe -u minecraft-server.service"
          "systemctl restart minecraft-server.service"
          "systemctl start minecraft-server.service"
          "systemctl status minecraft-server.service"
          "systemctl stop minecraft-server.service"
        ];
    }
  ];

  systemd.services.minecraft-server.serviceConfig.UMask = lib.mkForce "0007"; # change 0077 to 0007 to make group-writeable

  users.users = {
    minecraft.homeMode = "0770";

    steini = {
      uid = config.custom.ids.uids.steini;
      extraGroups = [ "minecraft" ];
      isNormalUser = true;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = [
        "${rootPath}/files/keys/id_rsa.steini.pub"
      ];
    };
  };

  zramSwap.enable = true;
}
