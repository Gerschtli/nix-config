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
      environment.systemPackages = with pkgs; [
        dmenu
        dropbox-cli
        dunst
        dwm
        gnome3.zenity
        google-chrome
        libreoffice
        pavucontrol
        qpdfview
        slock
        spotify
        sublime3
        thunderbird
        wmname
        xclip
        xss-lock
        xterm

        arc-icon-theme
        arc-theme
        xfce.thunar
        xfce.thunar_volman
      ];

      # GTK-Configuration
      environment.extraInit = ''
        export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="Arc"''}:${pkgs.arc-theme}/share/themes/Arc-Darker/gtk-2.0/gtkrc:$GTK2_RC_FILES
        export GTK_THEME=Arc-Darker
        export GTK_DATA_PREFIX=${config.system.path}
      '';

      environment.pathsToLink = [ "/share" ];

      fonts = {
        fonts = with pkgs; [
          fira-code
          fira-mono
        ];
      };

      hardware.pulseaudio.enable = true;

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

          # slock = pkgs.slock.override {
          #   patches =
          #     [ ../patches/slock-config.diff ];
          # };

          slock = pkgs.lib.overrideDerivation pkgs.slock (attrs: {
            patchPhase = attrs.patchPhase + " && patch < " + ../patches/slock-config.diff;
          });
        };
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
