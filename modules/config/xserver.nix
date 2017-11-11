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
      fonts.fonts = with pkgs; [
        fira-code
        fira-mono
      ];

      hardware.pulseaudio.enable = true;

      nixpkgs = {
        config.allowUnfree = true;

        overlays = map (file: import file) (getRecursiveFileList ../overlays);
      };

      programs = {
        slock.enable = true;

        ssh.askPassword = "";
      };

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
        dmenu
        dunst
        gnome3.zenity
        pavucontrol
        wmname
        xclip
        xss-lock
        xterm

        atom
        dropbox-cli
        eclipses.eclipse-sdk
        gimp
        google-chrome
        libreoffice
        nix-repl
        nox
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
