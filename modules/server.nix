{ config, pkgs, ... }:

let

  fetchBitBucket = pkgs.callPackage
    (
      builtins.scopedImport {
        __nixPath = [
          {
            path = pkgs.writeText "ssh_config" ''
              Host bitbucket.org
                IdentityFile /etc/nixos/misc/id_rsa.bitbucket-deploy
                StrictHostKeyChecking no
                UserKnownHostsFile=/dev/null
            '';
            prefix="ssh-config-file";
          }
        ] ++ __nixPath;
      }
      <nixpkgs/pkgs/build-support/fetchgit/private.nix>
    ) { };

  autoGoldenRiverJazztett = pkgs.stdenv.mkDerivation rec {
    name = "auto-golden-river-jazztett-${version}";
    version = "2017-09-03";

    src = fetchBitBucket {
      url = "git@bitbucket.org:tobiashapp/auto-golden-river-jazztett.git";
      rev = "82025349769f8c011791c212168eddd822d942c8";
      sha256 = "0kvy60s1p3kxxk43i6pd4gka64plqd46dh2dfs24wmz57rhzh10s";
    };

    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

    installPhase = "cp -R . \$out";

    postFixup = ''
      rm $out/dump.sql $out/install.sh
    '';
  };

  goldenRiverJazztett = pkgs.stdenv.mkDerivation rec {
    name = "golden-river-jazztett-${version}";
    version = "2017-09-03";

    src = fetchBitBucket {
      url = "git@bitbucket.org:tobiashapp/golden-river-jazztett.git";
      rev = "eac760aafff855f1bbb5430c54cec5b890df5d04";
      sha256 = "147v84r5p1hvdj9qx54q3p6xynf8hkic4lhh245rilvsmkawj28f";
    };

    phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

    installPhase = "cp -R . \$out";

    postFixup = ''
      find $out -maxdepth 1 -type f -exec rm {} \+
      find $out -type f -name '*.sass' -o -name '*.scss' -exec rm {} \+
    '';
  };

in

{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      30033 10011 41144 # TS3
      80 443 # httpd
    ];

    allowedUDPPorts = [
      9987 # TS3
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services = {
    fail2ban.enable = true;

    httpd = {
      enable = true;
      logPerVirtualHost = true;
      enablePHP = true;
      adminAddr = "tobias.happ@gmx.de";
      virtualHosts = [
        {
          hostName = "auto.goldenriverjazztett.de";
          documentRoot = "${autoGoldenRiverJazztett}";
          extraConfig = ''
            <Directory ${autoGoldenRiverJazztett}>
              Options -Indexes
              DirectoryIndex index.php
              AllowOverride All
            </Directory>
          '';
        }
        {
          hostName = "goldenriverjazztett.de";
          serverAliases = [ "www.goldenriverjazztett.de" ];
          documentRoot = "${goldenRiverJazztett}/public";
          extraConfig = ''
            <Directory ${goldenRiverJazztett}/public>
              Options -Indexes
              DirectoryIndex index.php
              AllowOverride All
            </Directory>
          '';
        }
      ];
    };

    mysql = {
      # set password with:
      # SET PASSWORD FOR root@localhost = PASSWORD('password');
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/var/db/mysql";
    };

    openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
      extraConfig = ''
        MaxAuthTries 3
      '';
    };

    teamspeak3.enable = true;
  };

  users.users.tobias.openssh.authorizedKeys.keyFiles = [
    ../misc/id_rsa.tobias-login.pub
  ];
}
