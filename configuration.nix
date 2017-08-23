{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/sda2";
    systemd-boot.enable = true;
  };

  hardware.pulseaudio.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  environment.systemPackages = with pkgs; [
    dmenu
    dwm
    ntfs3g
    git
    gnome2.zenity
    htop
    keychain
    neovim
    pavucontrol
    slock
    tmux
    wget
    xterm
    zsh
  ];

  fonts = {
    fonts = with pkgs; [
      fira-code
      fira-mono
    ];
  };

  networking = {
    extraHosts = ''
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

    usePredictableInterfaceNames = true;
  };

  nix.useSandbox = true;

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      dmenu = pkgs.dmenu.override {
        patches =
          [ patches/dmenu-config.diff ];
      };

      dwm = pkgs.dwm.override {
        patches =
          [ patches/dwm-config.diff ];
      };

      # see: https://github.com/NixOS/nixpkgs/issues/4017
      slock = pkgs.lib.overrideDerivation pkgs.slock (attrs: {
        patchPhase = attrs.patchPhase + " && patch < /etc/nixos/patches/slock-config.diff";
      });
    };
  };

  programs.zsh.enable = true;

  security = {
    sudo.extraConfig = "tobias ALL= NOPASSWD: /run/current-system/sw/sbin/shutdown";

    wrappers.slock.source = "${pkgs.slock}/bin/slock";
  };


  # List services that you want to enable:

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    xserver = {
      # Enable the X11 windowing system.
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

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  users.users = {
    root.shell = pkgs.zsh;

    tobias = {
      group = "wheel";
      extraGroups = [ "vboxusers" ];
      home = "/home/tobias";
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;
    };
  };

  virtualisation.virtualbox.host.enable = true;
}
