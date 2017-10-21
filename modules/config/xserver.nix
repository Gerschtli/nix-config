{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.xserver;

  getRecursiveFileList = import ../lib/get-recursive-file-list.nix { inherit lib; };
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
      # GTK-Configuration
      environment.extraInit = ''
        export GTK2_RC_FILES=${pkgs.writeText "iconrc" ''gtk-icon-theme-name="Arc"''
          }:${pkgs.arc-theme}/share/themes/Arc-Darker/gtk-2.0/gtkrc:$GTK2_RC_FILES
        export GTK_THEME=Arc-Darker
        export GTK_DATA_PREFIX=${config.system.path}
      '';

      fonts.fonts = with pkgs; [
        fira-code
        fira-mono
      ];

      hardware.pulseaudio.enable = true;

      nixpkgs = {
        config.allowUnfree = true;

        overlays = map (file: import file) (getRecursiveFileList ../overlays);
      };

      programs.slock.enable = true;

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

      users.users.tobias.packages = with pkgs; [
        arc-icon-theme
        arc-theme

        dmenu
        dunst
        gnome3.zenity
        libnotify
        pavucontrol
        wmname
        xclip
        xss-lock
        xterm

        dropbox-cli
        gimp
        gitAndTools.tig
        google-chrome
        libreoffice
        qpdfview
        soapui
        spotify
        sublime3
        thunderbird
        xfce.thunar
        xfce.thunar_volman
      ];
    }

    (mkIf cfg.laptop
      {
        environment.systemPackages = with pkgs; [
          # install globally because of icons not found
          networkmanagerapplet
        ];

        networking.networkmanager.enable = true;

        services = {
          logind.extraConfig = ''
            HandlePowerKey=ignore
          '';

          upower.enable = true;

          xserver.libinput = {
            enable = true;
            accelProfile = "flat";
            additionalOptions = ''
              Option "TappingButtonMap" "lmr"
            '';
          };
        };

        users.users.tobias.packages = with pkgs; [
          xorg.xbacklight
        ];
      }
    )

  ]);

}
