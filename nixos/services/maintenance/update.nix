{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.update;

  location = "/root/.nix-config";
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
        environment = {
          HOME = "/root";
          USER = "root";
        };
        path = [ pkgs.git pkgs.nix ];
        restartIfChanged = false;
        script = ''
          set -euo pipefail

          LAST_GENERATION="$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system)"

          ${pkgs.nix}/bin/nix flake update "${location}"
          ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "${location}" || :

          DIFF="$(${pkgs.nvd}/bin/nvd diff "$LAST_GENERATION" /nix/var/nix/profiles/system)"

          ${pkgs.git}/bin/git -C "${location}" add flake.lock
          ${pkgs.git}/bin/git -C "${location}" commit \
            --message "flake.inputs: automatic local update on ${config.networking.hostName}" \
            --message "$DIFF"
        '';
      };
    };

  };

}
