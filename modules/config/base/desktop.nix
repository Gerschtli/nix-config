{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.base.desktop;
in

{

  ###### interface

  options = {

    custom.base.desktop = {

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

      boot.tmpOnTmpfs = true;

      custom = {
        misc.dev.enable = true;

        programs = {
          dwm-status = {
            enable = cfg.wm == "dwm";
            order =
              if cfg.laptop
              then [ "cpu_load" "backlight" "audio" "battery" "time" ]
              else [ "cpu_load" "audio" "time" ];

            extraConfig = ''
              separator = "    "

              [audio]
              mute = "ﱝ"
              template = "{ICO} {VOL}%"
              icons = ["奄", "奔", "墳"]
            '';
          };

          pass = {
            enable = true;
            browserpass = true;
            x11Support = true;
          };
        };

        system.boot.mode = "efi";
      };

      environment.systemPackages = with pkgs; [
        exfat
        ntfs3g

        # for android mtp
        jmtpfs
        go-mtpfs
      ];

      fonts = {
        enableFontDir = true;
        enableGhostscriptFonts = true;
        fonts = with pkgs; [
          dejavu_fonts
          fira-code
          fira-mono
          nerdfonts
          source-code-pro
          ubuntu_font_family
        ];
      };

      hardware.pulseaudio.enable = true;

      nixpkgs.config.allowUnfree = true;

      programs = {
        slock.enable = true;

        ssh.askPassword = "";

        xss-lock = {
          enable = true;
          lockerCommand = "${config.security.wrapperDir}/slock";
        };
      };

      services = {
        udev.packages = with pkgs; [ android-udev-rules ];

        unclutter-xfixes = {
          enable = true;
          timeout = 3;
        };

        xserver = {
          enable = true;
          layout = "de";
          xkbOptions = "ctrl:nocaps";
          xkbVariant = "nodeadkeys";

          desktopManager.xterm.enable = false;

          displayManager = {
            job.logToFile = mkForce false;

            # FIXME: enable lightdm after https://github.com/NixOS/nixpkgs/issues/26687 got fixed
            lightdm = {
              enable = false;
              extraSeatDefaults = ''
                greeter-setup-script=${pkgs.numlockx}/bin/numlockx on
              '';
            };

            slim = {
              enable = true;
              defaultUser = "tobias";
              extraConfig = "numlock on";
            };
          };

          windowManager.dwm.enable = cfg.wm == "dwm";

          windowManager.i3 = {
            enable = cfg.wm == "i3";
            extraPackages = with pkgs; [ i3status-rust ];
            package = pkgs.i3-gaps;
          };
        };
      };

      sound.enable = true;

      systemd.mounts = [
        {
          where = "/tmp";
          what = "tmpfs";
          options = "mode=1777,strictatime,nosuid,nodev,size=8G";
        }
      ];

      users.users.tobias.packages = with pkgs; [
        dmenu
        dunst
        gnome3.zenity
        imagemagick
        libnotify # for notify-send
        pavucontrol
        playerctl
        rxvt_unicode-with-plugins
        wmname
        xclip
        xorg.xkill

        atom
        audacity
        eclipses.eclipse-sdk
        gimp
        google-chrome
        libreoffice
        musescore
        qpdfview
        # quodlibet
        soapui
        spotify
        sublime3
        thunderbird
        udisks
        vscode
      ];

      xdg = {
        autostart.enable = true;
        icons.enable = true;
        menus.enable = true;
        mime.enable = true;
      };
    }

    (mkIf cfg.laptop
      {
        custom.programs = {
          dwm-status.extraConfig = ''
            [backlight]
            template = "{ICO} {BL}%"
            icons = ["", "", ""]

            [battery]
            charging = ""
            discharging = ""
            no_battery = ""
            icons = ["", "", "", "", "", "", "", "", "", "", ""]
          '';

          nm-applet.enable = true;
        };

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
