{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = false;
    extraConfig = ''
      MaxAuthTries 3
    '';
  };

  users.users.tobias.openssh.authorizedKeys.keyFiles = [
    ../keys/id_rsa.tobias-login.pub
  ];
}
