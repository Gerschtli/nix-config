{ pkgs }:

# run for first time
# $ chown root:nixbld modules/secrets/id_rsa.bitbucket-deploy
# $ chmod 640 modules/secrets/id_rsa.bitbucket-deploy

pkgs.callPackage (
  builtins.scopedImport
    {
      __nixPath = [
        {
          path = pkgs.writeText "ssh_config" ''
            Host bitbucket.org
              IdentityFile /etc/nixos/modules/secrets/id_rsa.bitbucket-deploy
              StrictHostKeyChecking no
              UserKnownHostsFile=/dev/null
          '';
          prefix="ssh-config-file";
        }
      ] ++ __nixPath;
    }
    <nixpkgs/pkgs/build-support/fetchgit/private.nix>
  ) { }
