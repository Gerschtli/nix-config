{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    base.desktop.enable = true;

    services.openssh = {
      enable = true;
      forwardX11 = true;
    };
  };

  hardware.opengl.driSupport32Bit = true;

  home-manager.users = {
    root = import ./home-manager-configurations/home-files/helium/root.nix;
    tobias = import ./home-manager-configurations/home-files/helium/tobias.nix;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    # Toggle DVI-D-0 via:
    # xrandr --output "DVI-D-0" --left-of "HDMI-0" --auto
    # xrandr --output "DVI-D-0" --off
    xrandrHeads = [
      { output = "DVI-D-0";  monitorConfig = ''Option "Enable" "false"''; }
      { output = "HDMI-0"; primary = true; }
      { output = "DVI-I-1"; }
    ];
  };

  networking.hostName = "helium";
}
