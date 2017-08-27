{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    keychain
    neovim
    tmux
    wget
    zsh
  ];

  i18n = {
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  networking.usePredictableInterfaceNames = true;

  programs.zsh.enable = true;

  system.stateVersion = "17.03";

  time.timeZone = "Europe/Amsterdam";

  users.users = {
    root.shell = pkgs.zsh;

    tobias = {
      group = "wheel";
      home = "/home/tobias";
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;
    };
  };
}
