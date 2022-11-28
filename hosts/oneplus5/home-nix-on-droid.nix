{ config, lib, pkgs, ... }:

{
  custom = {
    base = {
      general.lightWeight = true;

      non-nixos = {
        enable = true;
        installNix = false;
        builders = [
          "ssh://private.argon aarch64-linux - 4"
        ];
      };
    };

    development.nix.nix-on-droid.enable = true;

    programs = {
      shell.logoutExtra = ''
        count="$(${pkgs.procps}/bin/ps ax | ${pkgs.gnugrep}/bin/grep proot-static | ${pkgs.gnugrep}/bin/grep -v grep | ${pkgs.coreutils}/bin/wc -l)"
        if [[ -z "$SSH_TTY" && "$SHLVL" == 1 && "$count" == 1 ]]; then
          ${pkgs.psmisc}/bin/killall ssh-agent sshd
        fi
      '';

      ssh = {
        cleanKeysOnShellStartup = false;
        controlMaster = "no";
        modules = [ "private" ];
      };

      # FIXME: tmux does not start
      tmux.enable = lib.mkForce false;
    };
  };

  # FIXME: without overrides produces warnings
  home.language = {
    collate = lib.mkForce null;
    ctype = lib.mkForce null;
    messages = lib.mkForce null;
    numeric = lib.mkForce null;
    time = lib.mkForce null;
  };
}
