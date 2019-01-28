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

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    # Toggle HDMI-0 via:
    # xrandr --output "HDMI-0" --left-of "DVI-I-1" --auto
    # xrandr --output "HDMI-0" --off
    xrandrHeads = [
      { output = "HDMI-0";  monitorConfig = ''Option "Enable" "false"''; }
      { output = "DVI-I-1"; primary = true; }
      { output = "DVI-D-0"; }
    ];
  };

  networking.hostName = "helium";
}
