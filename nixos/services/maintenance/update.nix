{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.update;

  flakeUrl = "github:Gerschtli/nix-config";
in

{

  ###### interface

  options = {

    custom.services.update = {
      enable = mkEnableOption "update module";

      interval = mkOption {
        type = types.str;
        description = ''
          Systemd calendar expression when to sync the backups. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.utils.systemd.timers.system-flake-update = {
      inherit (cfg) interval;
      description = "System flake update";

      serviceConfig = {
        path = [ pkgs.nix ]; # needed for nvd
        restartIfChanged = false;
        script = ''
          LAST_GENERATION="$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system)"

          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "${flakeUrl}" || :

          ${pkgs.nvd}/bin/nvd diff "$LAST_GENERATION" /nix/var/nix/profiles/system
        '';
      };
    };

  };

}
