{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnupg1
    pass
    pinentry_ncurses
  ];
}
