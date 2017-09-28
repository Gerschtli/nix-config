{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.xserver;
in

{

  ###### interface

  options = {

    custom.xserver = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure dwm and useful packages.
        '';
      };

      laptop = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to activate services for battery, network, backlight.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      environment = {

        # GTK-Configuration
        extraInit = ''
          export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="Arc"''
            }:${pkgs.arc-theme}/share/themes/Arc-Darker/gtk-2.0/gtkrc:$GTK2_RC_FILES
          export GTK_THEME=Arc-Darker
          export GTK_DATA_PREFIX=${config.system.path}
        '';

        systemPackages = with pkgs; [
          arc-icon-theme
          arc-theme
          dmenu
          dropbox-cli
          dunst
          dwm
          gimp
          gitAndTools.tig
          gnome3.zenity
          google-chrome
          libnotify
          libreoffice
          pavucontrol
          qpdfview
          slock
          soapui
          spotify
          sublime3
          thunderbird
          wmname
          xclip
          xfce.thunar
          xfce.thunar_volman
          xss-lock
          xterm
        ];

      };

      fonts.fonts = with pkgs; [
        fira-code
        fira-mono
      ];

      hardware.pulseaudio.enable = true;

      nixpkgs = {
        config.allowUnfree = true;

        overlays = with builtins; map
          (n: import (./overlays + ("/" + n)))
          (filter
            (n: match ".*\\.nix" n != null)
            (attrNames (readDir ./overlays)));
      };

      # for future releases
      # programs.slock.enable = true;

      security.wrappers.slock.source = "${pkgs.slock}/bin/slock";

      services.xserver = {
        enable = true;
        layout = "de";
        xkbVariant = "nodeadkeys";

        desktopManager.xterm.enable = false;

        displayManager = {
          job.logsXsession = false;

          logToJournal = false;

          slim = {
            defaultUser = "tobias";
            enable = true;
            extraConfig = "numlock on";
          };
        };

        windowManager.dwm.enable = true;
      };
    }

    (mkIf cfg.laptop
      {
        environment.systemPackages = with pkgs; [
          networkmanagerapplet
          xorg.xbacklight
        ];

        services = {
          logind.extraConfig = ''
            HandlePowerKey=ignore
          '';

          upower.enable = true;

          xserver.synaptics = {
            enable = true;
            twoFingerScroll = true;
            buttonsMap = [ 1 3 2 ];
          };
        };

        networking.networkmanager.enable = true;
      }
    )

  ]);

}
