{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmenu
    dropbox-cli
    dwm
    gnome2.zenity
    google-chrome
    qpdfview
    slock
    spotify
    sublime3
    libreoffice
    thunderbird
    wmname
    xclip
    xss-lock
    xterm
  ];

  fonts = {
    fonts = with pkgs; [
      fira-code
      fira-mono
    ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    dmenu = pkgs.dmenu.override {
      patches =
        [ ../patches/dmenu-config.diff ];
    };

    dwm = pkgs.dwm.override {
      patches =
        [ ../patches/dwm-config.diff ];
    };

    slock = pkgs.lib.overrideDerivation pkgs.slock (attrs: {
      patchPhase = attrs.patchPhase + " && patch < " + ../patches/slock-config.diff;
    });
  };

  security = {
    sudo.extraConfig = "tobias ALL= NOPASSWD: /run/current-system/sw/sbin/shutdown";

    wrappers.slock.source = "${pkgs.slock}/bin/slock";
  };

  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "nodeadkeys";

    desktopManager.xterm.enable = false;

    displayManager.slim = {
      defaultUser = "tobias";
      enable = true;
      extraConfig = "numlock on";
    };
  };
}
