{ config, lib, pkgs, inputs, utils, ... }:

{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  custom = {
    agenix.secrets = [ "passwd-root-neon" "passwd-tobias-neon" ];

    base.desktop = {
      enable = true;
      laptop = true;
    };

    programs.docker.enable = true;

    system = {
      boot.mode = "efi";

      nvidia-optimus = {
        enable = true;
        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  security.pam.services.i3lock.enable = true;

  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';

  # agenix needs to wait for impermanence
  system.activationScripts.agenixNewGeneration.deps = [ "persist-files" ];

  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/docker"
      "/var/lib/fail2ban"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/upower"
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
      { file = "/root/.age/key.txt"; parentDirectory = { mode = "0700"; }; }
    ];
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  boot.initrd.systemd.services.rollback =
    let
      device = "/dev/vg/root";
      mountPoint = "/btrfs_tmp";
      oldRootsDir = "old_roots";
    in
    {
      description = "Rollback BTRFS root subvolume to a pristine state";

      # Specify dependencies explicitly
      unitConfig.DefaultDependencies = false;
      # The script needs to run to completion before this service is done
      serviceConfig.Type = "oneshot";
      # This service is required for boot to succeed
      wantedBy = [ "initrd.target" ];
      # Should complete before any file systems are mounted
      before = [ "sysroot.mount" ];

      # Wait for the disk to appear
      requires = [ "${utils.escapeSystemdPath device}.device" ];
      after = [
        "${utils.escapeSystemdPath device}.device"
        # Allow hibernation to resume before trying to alter any data
        "local-fs-pre.target"
      ];

      script = ''
        mkdir --parents ${mountPoint}
        mount ${device} ${mountPoint}
        trap 'umount ${mountPoint}' EXIT

        echo "creating /root snapshot..."
        mkdir --parents ${mountPoint}/${oldRootsDir}
        timestamp="$(date --date="@$(stat -c %Y ${mountPoint}/root)" "+%Y-%m-%d_%H:%M:%S")"
        mv ${mountPoint}/root "${mountPoint}/${oldRootsDir}/$timestamp"

        echo "creating blank /root subvolume..."
        btrfs subvolume create ${mountPoint}/root

        echo "deleting previous /root snapshots..."
        # keep last 5 entries
        for i in $(ls -1dtr ${mountPoint}/${oldRootsDir}/* | head -n -5); do
          echo "deleting $i..."
          btrfs subvolume delete --recursive "$i"
        done
      '';
    };

  users = {
    mutableUsers = false;

    users = {
      root.hashedPasswordFile = config.age.secrets.passwd-root-neon.path;
      tobias.hashedPasswordFile = config.age.secrets.passwd-tobias-neon.path;
    };
  };
}
