{ config, lib, pkgs, homeModules, inputs, rootPath, ... }@configArgs:

let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{
  # FIXME: Move sshd config to nix-on-droid
  build.activation.sshd = ''
    run mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    run cat "${rootPath}/files/keys/id_rsa.tobias.pub" > "${config.user.home}/.ssh/authorized_keys"

    if [[ ! -d "${sshdDirectory}" ]]; then
      run rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      run mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      verboseEcho "Generating host keys..."
      run ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""
      verboseEcho "Writing sshd_config..."
      run echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort 8022\n" > "${sshdTmpDirectory}/sshd_config"

      run mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';

  environment = {
    etcBackupExtension = ".nod-bak";
    motd = null;

    packages = with pkgs; [
      diffutils
      findutils
      gawk
      gnugrep
      gnused
      gnutar
      hostname
      man
      ncurses
      procps
      psmisc

      (writeScriptBin "sshd-start" ''
        #!${runtimeShell}

        echo "Starting sshd in non-daemonized way on port 8022"
        ${openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
      '')
    ];
  };

  home-manager = {
    inherit (commonConfig.homeManager.baseConfig)
      backupFileExtension
      extraSpecialArgs
      sharedModules
      useGlobalPkgs
      useUserPackages
      ;

    config = commonConfig.homeManager.userConfig "pixel7a" "nix-on-droid";
  };

  nix = { inherit (commonConfig.nix) package; };

  system.stateVersion = "24.05";

  terminal.font =
    let
      fontPackage = pkgs.nerdfonts.override {
        fonts = [ "UbuntuMono" ];
      };
      fontPath = "/share/fonts/truetype/NerdFonts/UbuntuMonoNerdFont-Regular.ttf";
    in
    fontPackage + fontPath;

  time.timeZone = "Europe/Berlin";

  user.shell = "${pkgs.zsh}/bin/zsh";
}
