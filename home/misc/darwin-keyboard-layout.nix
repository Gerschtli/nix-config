{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    ;

  cfg = config.custom.misc.darwin-keyboard-layout;

  bundle = pkgs.fetchFromGitHub {
    owner = "sebroeder";
    repo = "osx-keyboard-layout-german-no-deadkeys";
    rev = "00d14e4bf6ec81093862109b83a3a2fb1021c631";
    hash = "sha256-skWq3Wc/DGKCw9vKAOyHYSfMans0uQBAeWd2xyQw5DU=";
  };

  installDir = "${config.home.homeDirectory}/Library/Keyboard Layouts/German No Deadkeys.bundle";
in

{

  ###### interface

  options = {

    custom.misc.darwin-keyboard-layout.enable = mkEnableOption "german keyboard layout without dead keys";

  };


  ###### implementation

  config = {

    home.activation.darwin-keyboard-layout = lib.hm.dag.entryAnywhere
      (
        if cfg.enable
        then ''
          if [[ -d "${installDir}" ]]; then
            echo "Skipping installation of darwin keyboard layout because it is already installed at ${installDir}"
          else
            echo "Installing darwin keyboard layout into ${installDir}..."
            $DRY_RUN_CMD mkdir --parents $VERBOSE_ARG "${installDir}"
            $DRY_RUN_CMD cp --recursive $VERBOSE_ARG "${bundle}/German No Deadkeys.bundle"/* "${installDir}"
          fi
        '' else ''
          if [[ -d "${installDir}" ]]; then
            echo "Uninstalling darwin keyboard layout at ${installDir}..."
            $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod --recursive +w $VERBOSE_ARG "${installDir}"
            $DRY_RUN_CMD rm --recursive $VERBOSE_ARG "${installDir}"
          fi
        ''
      );

  };

}
