{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    dmenu
    dwm
    gnome2.zenity
    ntfs3g
    pavucontrol
    slock
    xterm
  ];

  fonts = {
    fonts = with pkgs; [
      fira-code
      fira-mono
    ];
  };

  hardware.pulseaudio.enable = true;

  networking.extraHosts = ''
    # astarget
    192.168.35.10   www.astarget.local   fb.astarget.local
    192.168.35.10   test.astarget.local  test.fb.astarget.local

    # cbn/backend
    192.168.56.202  backend.local

    # cbn/frontend
    192.168.56.201  www.accessoire.local.de
    192.168.56.201  www.getprice.local.at
    192.168.56.201  www.getprice.local.ch
    192.168.56.201  www.getprice.local.de
    192.168.56.201  www.handys.local.com
    192.168.56.201  www.preisvergleich.local.at
    192.168.56.201  www.preisvergleich.local.ch
    192.168.56.201  www.preisvergleich.local.eu
    192.168.56.201  www.preisvergleich.local.org
    192.168.56.201  www.shopping.local.at
    192.168.56.201  www.shopping.local.ch
    192.168.56.201  www.testit.local.de
  '';

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
    sudo.extraConfig = "tobias ALL= NOPASSWD: /run/current-system/sw/sbin/shutdown";

    wrappers.slock.source = "${pkgs.slock}/bin/slock";
  };

  services = {
    printing.enable = true;

    xserver = {
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
  };

  users.users.tobias.extraGroups = [ "vboxusers" ];

  virtualisation.virtualbox.host.enable = true;
}
