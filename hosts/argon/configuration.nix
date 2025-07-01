{ config, lib, pkgs, rootPath, ... }:

{
  imports = [
    ./configuration-steini.nix
  ];

  custom = {
    applications.original-chattengauer.enable = true;

    base.server.enable = true;

    programs.docker.enable = true;

    services = {
      backup.enable = true;

      minecraft-server.enable = true;

      openssh.enable = true;
    };

    system.boot.mode = "efi";
  };

  users.users.docker = {
    isSystemUser = true;
    group = "docker";
    openssh.authorizedKeys.keyFiles = [
      "${rootPath}/files/keys/id_rsa.docker.pub"
    ];
  };

  zramSwap.enable = true;
}
