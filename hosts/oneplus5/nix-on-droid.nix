{ config, lib, pkgs, homeModules, rootPath, ... }:

let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";
in

{
  build.activation.sshd = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    $DRY_RUN_CMD cat ${rootPath + "/files/keys/id_rsa.tobias.pub"} > "${config.user.home}/.ssh/authorized_keys"

    if [[ ! -d "${sshdDirectory}" ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""
      $VERBOSE_ECHO "Writing sshd_config..."
      $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort 8022\n" > "${sshdTmpDirectory}/sshd_config"

      $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';

  environment.etcBackupExtension = ".nod-bak";

  environment.packages = with pkgs; [
    gnutar
    gzip
    (writeScriptBin "sshd-start" ''
      #!${runtimeShell}

      echo "Starting sshd in non-daemonized way on port 8022"
      ${openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
    '')
  ];

  home-manager = {
    backupFileExtension = "hm-bak";
    config = import (rootPath + "/hosts/oneplus5/home-nix-on-droid.nix") { inherit homeModules rootPath; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix = {
    package = pkgs.nix_2_4;
    extraConfig = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "21.11";

  time.timeZone = "Europe/Berlin";

  user.shell = "${pkgs.zsh}/bin/zsh";
}
