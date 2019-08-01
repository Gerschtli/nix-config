{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.ssh;

  customLib = import ../lib args;

  directorySource = toString ../secrets/ssh/modules;
  directoryDestination = "${config.home.homeDirectory}/.ssh/modules";

  modules = customLib.getDirectoryList directorySource;
in

{

  ###### interface

  options = {

    custom.ssh.enable = mkEnableOption "ssh config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.ssh = {
      enable = true;

      compression = true;
      serverAliveInterval = 30;
      hashKnownHosts = true;
      controlMaster = "auto";
      controlPath = "~/.ssh/socket-%r@%h-%p";
      controlPersist = "10m";

      extraConfig = ''
        CheckHostIP yes
        ConnectTimeout 60
        EnableSSHKeysign yes
        ExitOnForwardFailure yes
        ForwardX11Trusted yes
        IdentitiesOnly yes
        NoHostAuthenticationForLocalhost yes
        Protocol 2
        PubKeyAuthentication yes
        SendEnv LANG LC_*
        ServerAliveCountMax 30
      '';

      matchBlocks = mkMerge (
        map
          (module: (import module { path = "${toString module}"; }).matchBlocks)
          modules
      );
    };

    systemd.user.services.install-ssh-keys = {
      Unit = {
        Description = "Install ssh keys";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScript "install-ssh-keys.sh" ''
          #!${pkgs.bash}/bin/bash

          if [[ ! -d "${directorySource}" || ! -r "${directorySource}" ]]; then
            >&2 echo "${directorySource} has to be a readable directory for user '${config.home.username}'"
            exit 1
          fi

          rm --verbose --recursive "${directoryDestination}"
          mkdir --parents "${directoryDestination}"

          cd "${directorySource}"
          find . -type f -path "*/keys/*" -exec cp --archive --verbose --parents "{}" "${directoryDestination}" \;
        ''}";
      };
    };

  };

}
