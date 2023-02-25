rootPath:

{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.vim ];

  nixos-shell.mounts = {
    mountHome = false;
    mountNixProfile = false;
    cache = "none";
    extraMounts."/tmp/nix-config" = {
      target = rootPath;
      cache = "none";
    };
  };

  system.stateVersion = "22.11";

  virtualisation = {
    cores = 8;
    diskSize = 30 * 1024; # in MB
    memorySize = 8 * 1024; # in MB
    writableStoreUseTmpfs = false;
  };
}
