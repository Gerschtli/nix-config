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
        dwm
        gnome2.zenity
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
      ];

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

          slock = pkgs.lib.overrideDerivation pkgs.slock (attrs: {
            patchPhase = attrs.patchPhase + " && patch < " + ../patches/slock-config.diff;
          });
        };
      };

      security.wrappers.slock.source = "${pkgs.slock}/bin/slock";

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

    (mkIf cfg.laptop
      {
        environment.systemPackages = with pkgs; [
          networkmanagerapplet
          xorg.xbacklight
        ];

        services = {
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
