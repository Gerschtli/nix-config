{ pkgs }:

pkgs.callPackage (
  builtins.scopedImport
    {
      __nixPath = [
        {
          path = pkgs.writeText "ssh_config" ''
            Host bitbucket.org
              IdentityFile /etc/nixos/keys/id_rsa.bitbucket-deploy
              StrictHostKeyChecking no
              UserKnownHostsFile=/dev/null
          '';
          prefix="ssh-config-file";
        }
      ] ++ __nixPath;
    }
    <nixpkgs/pkgs/build-support/fetchgit/private.nix>
  ) { }
