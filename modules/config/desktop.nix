{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.desktop;

  customLib = import ../lib args;
in

{

  ###### interface

  options = {

    custom.desktop = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable basic desktop config with dwm.
        '';
      };

      laptop = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to activate services for battery, network, backlight.
        '';
      };

      wm = mkOption {
        type = types.enum [ "dwm" "i3" ];
        default = "dwm";
        description = ''
          Set whether dwm or i3 should be used as windows manager.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {

      custom = {
        applications.pass = {
          enable = true;
          browserpass = true;
        };

        boot.isEFI = true;

        dev.enable = true;
      };

      environment.systemPackages = with pkgs; [
        exfat
        ntfs3g
      ];

      fonts = {
        enableFontDir = true;
        enableGhostscriptFonts = true;
        fonts = with pkgs; [
          corefonts
          dejavu_fonts
          fira-code
          fira-mono
          font-awesome-ttf
          google-fonts
          inconsolata
          ipafont
          nerdfonts
          powerline-fonts
          source-code-pro
          terminus_font
          ubuntu_font_family
          unifont
        ];
      };

      hardware.pulseaudio.enable = true;

      nixpkgs = {
        config.allowUnfree = true;

        overlays = map (file: import file) (customLib.getRecursiveFileList ../overlays);
      };

      programs = {
        slock.enable = true;

        ssh.askPassword = "";
      };

      services.xserver = {
        enable = true;
        layout = "de";
        xkbOptions = "ctrl:nocaps";
        xkbVariant = "nodeadkeys";

        desktopManager.xterm.enable = false;

        displayManager.slim = {
          enable = true;
          defaultUser = "tobias";
          extraConfig = "numlock on";
        };

        windowManager.dwm.enable = cfg.wm == "dwm";

        windowManager.i3 = {
          enable = cfg.wm == "i3";
          extraPackages = [ ];
        };
      };

      sound.enable = true;

      users.users.tobias.packages = with pkgs; [
        dmenu
        dunst
        gnome3.zenity
        libnotify # for notify-send
        pavucontrol
        wmname
        xclip
        xss-lock
        xterm

        atom
        eclipses.eclipse-sdk
        gimp
        google-chrome
        libreoffice
        qpdfview
        soapui
        spotify
        sublime3
        thunderbird
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
