{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.nvidia-optimus;
in

{

  ###### interface

  options = {

    custom.system.nvidia-optimus = {
      enable = mkEnableOption "nvidia optimus";

      enableOffload = mkEnableOption "offload per default";

      amdgpuBusId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Bus ID of the AMD GPU.
        '';
      };

      nvidiaBusId = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Bus ID of the NVIDIA GPU.
        '';
      };
    };

  };


  ###### implementation

  config = {

    assertions = [
      {
        assertion = cfg.enable -> cfg.amdgpuBusId != null && cfg.nvidiaBusId != null;
        message = "You need to configure bus ID options if you enable the module.";
      }
    ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec -a "$0" "$@"
      '')
    ];

    hardware.nvidia.prime = {
      inherit (cfg) amdgpuBusId nvidiaBusId;
      offload.enable = cfg.enableOffload;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    specialisation = mapAttrs
      (name: option: {
        configuration = {
          hardware.nvidia.prime.offload.enable = lib.mkForce option;

          system.nixos.tags = [ name ];
        };
      })
      {
        external-display = false;
        offload = true;
      };

  };

}
