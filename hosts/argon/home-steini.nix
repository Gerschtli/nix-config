{ config, lib, pkgs, ... }:

let
  motdPath = ".motd";
in

{
  custom.base.general.minimal = true;

  home = {
    file.${motdPath}.text = ''
      Minecraft state directory:    /var/lib/minecraft
      Start/stop minecraft server:  sudo systemctl <start|stop|restart> minecraft-server.service
      Status of minecraft server:   sudo systemctl status minecraft-server.service
      Logs of minecraft server:     sudo journalctl -xe -u minecraft-server.service
    '';

    packages = [ pkgs.nano ];
  };

  programs.zsh.loginExtra = ''
    echo
    echo "==================== BASIC INFOS ===================="
    cat ${config.home.homeDirectory}/${motdPath}
    echo
    echo "See ~/${motdPath} file"
    echo "====================================================="
    echo
  '';
}
