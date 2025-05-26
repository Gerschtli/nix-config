{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    ;

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

        tmp.useTmpfs = true;
      };

      custom.system.boot.mode = "efi";

      environment.systemPackages = with pkgs; [
        exfat
        ntfs3g

        jmtpfs # use like jmtpfs /mnt
      ];

      fonts = {
        enableDefaultPackages = true;
        enableGhostscriptFonts = true;
        fontDir.enable = true;

        packages = with pkgs; [
          nerd-fonts.ubuntu-mono
          source-code-pro
        ];
      };

      hardware.graphics.enable = true;

      programs.ssh.askPassword = "";

      services = {
        pipewire.enable = false;

        pulseaudio.enable = true;

        xserver = mkIf cfg.enableXserver {
          enable = true;

          displayManager.lightdm.enable = true;

          # FIXME: why is this line needed? ~/.xsession is executed anyway..
          windowManager.dwm.enable = true;
        };
      };

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
        hardware.bluetooth = {
          enable = true;
          disabledPlugins = [ "sap" ];
          # fix error logs on boot
          settings.General.Experimental = true;
        };

        networking.networkmanager = {
          enable = true;
          plugins = mkForce [ ]; # FIXME: disabled because openconnect is not substitutable currently
        };

        programs.light.enable = true;

        services = {
          blueman.enable = true;

          libinput = mkIf cfg.enableXserver {
            enable = true;
            touchpad = {
              accelProfile = "flat";
              additionalOptions = ''
                Option "TappingButtonMap" "lmr"
              '';
            };
          };

          logind.extraConfig = ''
            HandlePowerKey=ignore
          '';

          # for bluetooth support
          pulseaudio.package = pkgs.pulseaudioFull;

          tlp.enable = true;

          upower.enable = true;
        };

        users.users.tobias.extraGroups = [ "networkmanager" "video" ];
      }
    )

  ]);

}
