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

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
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
  };

  security = {
    sudo.extraConfig = ''
      Cmnd_Alias SYS_HALT = /run/current-system/sw/bin/systemctl halt
      Cmnd_Alias SYS_HIBERNATE = /run/current-system/sw/bin/systemctl hibernat
      Cmnd_Alias SYS_HYBRID = /run/current-system/sw/bin/systemctl hybrid-sleep
      Cmnd_Alias SYS_REBOOT = /run/current-system/sw/bin/systemctl reboot
      Cmnd_Alias SYS_SUSPEND = /run/current-system/sw/bin/systemctl suspend

      tobias ALL= NOPASSWD: SYS_HALT, SYS_HIBERNATE, SYS_HYBRID, SYS_REBOOT, SYS_SUSPEND
    '';

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
