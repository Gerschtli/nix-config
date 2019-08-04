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

      programs.ssh.askPassword = "";

      services = {
        udev.packages = with pkgs; [ android-udev-rules ];

        unclutter-xfixes = {
          enable = true;
          timeout = 3;
        };

        xserver = {
          enable = true;

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
        imagemagick
        pavucontrol
        playerctl
        xclip
        xorg.xkill

        audacity
        eclipses.eclipse-sdk
        gimp
        google-chrome
        jetbrains.idea-ultimate
        libreoffice
        musescore
        nomacs
        qpdfview
        # quodlibet
        soapui
        spotify
        thunderbird
        udisks
      ];

      xdg = {
        autostart.enable = true;
        icons.enable = true;
        menus.enable = true;
        mime.enable = true;
        sounds.enable = true;
      };
    }

    (mkIf cfg.laptop
      {
        networking.networkmanager.enable = true;

        programs.light.enable = true;

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

        users.users.tobias.extraGroups = [ "video" ];
      }
    )

  ]);

}
