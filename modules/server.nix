{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      30033 10011 41144 # TS3
    ];

    allowedUDPPorts = [
      9987 # TS3
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services = {
    fail2ban.enable = true;

    openssh = {
      enable = true;
      permitRootLogin = "yes";
      extraConfig = ''
        MaxAuthTries 3
      '';
    };

    teamspeak3.enable = true;
  };

  users.users.tobias.openssh.authorizedKeys.keyFiles = [
    ../misc/id_rsa.tobias-login.pub
  ];
}
