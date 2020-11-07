{ config, lib, pkgs, ... } @ args:

with lib;

{
  imports = [ ../../modules ];

  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      general.extendedPath = [
        "$HOME/bin"
        "$HOME/.local/bin"
      ];

      non-nixos.enable = true;
    };

    development = {
      nodejs.enable = true;
      php.enable = true;
      vagrant.enable = true;
    };

    misc.util-bins.bins = [ "csv-check" ];

    programs.ssh.modules = [ "pveu" ];

    services.dwm-status.useGlobalAlsaUtils = true;

    xsession = {
      useSlock = true;

      useSudoForHibernate = true;
    };
  };

  home = {
    packages = with pkgs; [
      python37Packages.sqlparse
      rustup
      # FIXME: disabled because of build failure of libguestfs
      # vagrant

      avocode
      curl
      docker_compose
      mysql-workbench
      nodejs-10_x
      rage
      simplescreenrecorder
      slack
      soapui
    ];

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";

      NIX_PATH = "nixpkgs=/home/tobias/.nix-defexpr/channels/nixpkgs:/home/tobias/.nix-defexpr/channels";
    };

    homeDirectory = "/home/tobias";
    username = "tobias";
  };

  # FIXME: move to some module
  nixpkgs =  {
    config = import ../../modules/files/config.nix;
    overlays =
      let
        customLib = import ../../modules/lib args;
        overlays = customLib.getFileList ../../modules/overlays;
      in
        map import overlays;
  };

  programs.autorandr = {
    enable = true;

    profiles =
      let
        fingerprints = {
          eDP-1 = "00ffffffffffff004d10ad14000000002a1c0104a51d11780ede50a3544c99260f5054000000010101010101010101010101010101014dd000a0f0703e803020350026a510000018a4a600a0f0703e803020350026a510000018000000fe00305239394b804c513133334431000000000002410328011200000b010a20200041";
          DVI-I-1-1 = "00ffffffffffff0022640000000000001c1b0103803c2278ea9055a75553a028135054bfef8081c08140818090409500a940b300d1c0565e00a0a0a029503020350055502100001a000000ff0031323334353637383930313233000000fc0048513237325050420a20202020000000fd00384b1f591e000a20202020202001fe020324f14f9005040302071601141f12131e1607230907078301000067030c002000383c023a801871382d40582c450055502100001f011d8018711c1620582c250055502100009f011d007251d01e206e28550055502100001f8c0ad08a20e02d10103e960055502100001900000000000000000000000000000000000000b2o";
        };

        mkConfigObject = config: mkMerge [
          {
            DP-1.enable = mkDefault false;
            DP-2.enable = mkDefault false;
            DVI-I-1-1.enable = mkDefault false;
            eDP-1.enable = mkDefault true;
          }

          config
        ];
      in
        {
          docked = {
            fingerprint = {
              inherit (fingerprints) eDP-1 DVI-I-1-1;
            };

            config = mkConfigObject {
              DVI-I-1-1 = {
                enable = true;
                primary = true;
                # FIXME: add when https://github.com/rycee/home-manager/pull/1283 gets merged into stable
                #crtc = 0;
                mode = "2560x1440";
                position = "0x0";
                rate = "59.95";
              };

              eDP-1 = {
                # FIXME: add when https://github.com/rycee/home-manager/pull/1283 gets merged into stable
                #crtc = 1;
                mode = "1368x768";
                position = "2560x0";
                rate = "59.88";
              };
            };
          };

          station = {
            fingerprint = {
              inherit (fingerprints) DVI-I-1-1;
            };

            config = mkConfigObject {
              DVI-I-1-1 = {
                enable = true;
                primary = true;
                # FIXME: add when https://github.com/rycee/home-manager/pull/1283 gets merged into stable
                #crtc = 0;
                mode = "2560x1440";
                position = "0x0";
                rate = "59.95";
              };

              eDP-1.enable = false;
            };
          };

          mobile = {
            fingerprint = {
              inherit (fingerprints) eDP-1;
            };

            config = mkConfigObject {
              eDP-1 = {
                primary = true;
                # FIXME: add when https://github.com/rycee/home-manager/pull/1283 gets merged into stable
                #crtc = 0;
                mode = "1920x1080";
                position = "0x0";
                rate = "59.96";
              };
            };
          };
        };
  };

  xsession.profileExtra = ''
    exec > ~/.xsession-errors 2>&1
    autorandr --change | grep detected > /dev/null 2>&1 || autorandr --change docked
  '';
}
