{ config, lib, pkgs, homeModules, rootPath, ... }:

{
  environment = {
    etcBackupExtension = ".nod-bak";

    etc."ssh/authorized_keys".source = rootPath + "/files/keys/id_rsa.tobias.pub";

    packages = with pkgs; [
      gnutar
      gzip
    ];
  };

  home-manager = {
    backupFileExtension = "hm-bak";
    config = rootPath + "/hosts/oneplus5/home-nix-on-droid.nix";
    extraSpecialArgs = { inherit rootPath; };
    sharedModules = homeModules;
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.openssh = {
    enable = true;
    extraConfig = ''
      AuthorizedKeysFile /etc/ssh/authorized_keys
    '';
  };

  system.stateVersion = "22.05";

  time.timeZone = "Europe/Berlin";

  user.shell = "${pkgs.zsh}/bin/zsh";
}
