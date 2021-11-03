{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.base.desktop;
in

{

  ###### interface

  options = {

    custom.base.desktop = {
      enable = mkEnableOption "basic desktop config";

      enableXserver = mkEnableOption "xserver config" // { default = true; };

      laptop = mkEnableOption "services and config for battery, network, backlight";
    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      boot = {
        # The default max inotify watches is 8192.
        # Nowadays most apps require a good number of inotify watches,
        # the value below is used by default on several other distros.
        kernel.sysctl."fs.inotify.max_user_watches" = 524288;

        tmpOnTmpfs = true;
      };

      custom.system.boot.mode = "efi";

      environment.systemPackages = with pkgs; [
        exfat
        ntfs3g

        # for android mtp
        jmtpfs
        go-mtpfs
      ];

      fonts = {
        enableDefaultFonts = true;
        enableGhostscriptFonts = true;
        fontDir.enable = true;

        fonts = with pkgs; [
          nur-gerschtli.nerdfonts-ubuntu-mono
          source-code-pro
          ubuntu_font_family
        ];
      };

      hardware = {
        opengl.enable = true;
        pulseaudio.enable = true;
      };

      nixpkgs.config.allowUnfree = true;

      programs = {
        # TODO: move to home-manager-configuration
        browserpass.enable = true;

        ssh.askPassword = "";
      };

      services = {
        udev.packages = with pkgs; [ android-udev-rules ];

        xserver = mkIf cfg.enableXserver {
          enable = true;

          # FIXME: enable lightdm after https://github.com/NixOS/nixpkgs/issues/26687 got fixed
          displayManager.lightdm.enable = true;

          # FIXME: why is this line needed? ~/.xsession is executed anyway..
          windowManager.dwm.enable = true;
        };
      };

      sound.enable = true;

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
        hardware = {
          bluetooth.enable = true;

          # for bluetooth support
          pulseaudio.package = pkgs.pulseaudioFull;
        };

        networking.networkmanager.enable = true;

        programs.light.enable = true;

        services = {
          blueman.enable = true;

          logind.extraConfig = ''
            HandlePowerKey=ignore
          '';

          upower.enable = true;

          xserver.libinput = mkIf cfg.enableXserver {
            enable = true;
            touchpad = {
              accelProfile = "flat";
              additionalOptions = ''
                Option "TappingButtonMap" "lmr"
              '';
            };
          };
        };

        users.users.tobias.extraGroups = [ "video" ];
      }
    )

  ]);

}
