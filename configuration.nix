# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
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

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    dmenu
    dwm
    ntfs3g
    git
    gnome2.zenity
    htop
    neovim
    pavucontrol
    slock
    tmux
    xterm
    zsh
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
      dwm = pkgs.dwm.override {
        patches =
          [ ./dwm-config.diff ];
      };

#      slock = pkgs.slock.override {
#        patchPhase =
#          "sed -i '/chmod u+s/d' Makefile && patch < /etc/nixos/slock-config.diff";
#      };
    };
  };

  security = {
    sudo.extraConfig = "tobias ALL= NOPASSWD: /run/current-system/sw/sbin/shutdown";

    wrappers.slock.source = "${pkgs.slock.out}/bin/slock";
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

      displayManager.slim = {
        defaultUser = "tobias";
        enable = true;
      };
    };
  };

  programs.zsh.enable = true;

  users.users = {
    root = {
      isSystemUser = true;
      shell = pkgs.zsh;
    };

    tobias = {
      group = "wheel";
      home = "/home/tobias";
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;
    };
  };

  virtualisation.virtualbox.host.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
}
