{ config, lib, pkgs, inputs, ... }:

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

  # agenix needs to wait for impermanence
  system.activationScripts.agenixNewGeneration.deps = [ "persist-files" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/root/.local/share/nix"
      "/root/.nix-config"
      "/var/lib/docker"
      "/var/lib/fail2ban"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
      "/root/.bash_history"
      "/root/.config/zsh/.zsh_history"
      { file = "/root/.age/key.txt"; parentDirectory = { mode = "0700"; }; }
      { file = "/root/.ssh/known_hosts"; parentDirectory = { mode = "0700"; }; }
    ];

    users.tobias = {
      directories = [
        ".PortfolioPerformance"
        ".config/Code"
        ".config/audacity"
        ".config/google-chrome"
        ".config/pulse"
        ".config/spotify"
        ".config/vlc"
        ".eclipse" # for portfolio-performance
        ".files"
        ".local/share/direnv"
        ".local/share/nix"
        ".local/state/pnpm"
        ".password-store"
        ".rustup"
        ".thunderbird"
        ".vscode"
        "Documents"
        "Downloads"
        "projects"
        { directory = ".gnupg"; mode = "0700"; }
      ];
      files = [
        ".bash_history"
        ".config/QtProject.conf"
        ".config/gtk-3.0/bookmarks"
        ".config/zsh/.zsh_history"
        { file = ".age/key.txt"; parentDirectory = { mode = "0700"; }; }
        { file = ".ssh/known_hosts"; parentDirectory = { mode = "0700"; }; }
      ];
    };
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt

    mount -o subvol=/ /dev/vg/root /mnt

    # remove auto-created subvolumes in /root subvolume
    # - /root/srv
    # - /root/var/lib/portables # from systemd
    # - /root/var/lib/machines # from systemd
    btrfs subvolume list -o /mnt/root \
      | cut -f9 -d' ' \
      | while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
      done

    echo "creating /root snapshot..."
    btrfs subvolume snapshot -r /mnt/root "/mnt/root-$(date +"%Y-%m-%d-%H-%M-%S")"

    echo "deleting /root subvolume..."
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    umount /mnt
  '';

  users = {
    mutableUsers = false;

    users = {
      root.passwordFile = config.age.secrets.passwd-root-neon.path;
      tobias.passwordFile = config.age.secrets.passwd-tobias-neon.path;
    };
  };
}
