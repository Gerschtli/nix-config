{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    mapAttrsToList
    mkBefore
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    optionalString
    types
    ;

  cfg = config.custom.programs.shell;

  dynamicShellInitModule = types.submodule (_: {
    options = {
      condition = mkOption {
        type = types.str;
        example = "available cargo";
        description = ''
          Condition to be matched before the provided aliases and config are set.
          The value has to be a bash/zsh expression to be placed into an `if`.
        '';
      };

      initExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when `condition` is met. Commands need
          to be idempotent as they are potentially executed mulitple times.
        '';
      };

      shellAliases = mkOption {
        default = { };
        type = types.attrsOf types.str;
        example = { ll = "ls -l"; ".." = "cd .."; };
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
      };
    };
  });

  initExtra = mkMerge [
    # mkBefore is needed because these commands need to be executed early in
    # the config
    (mkBefore ''
      is_bash() {
        [[ -n "''${BASH_VERSION-}" ]]
      }

      ${optionalString (!config.custom.base.general.darwin) ''
        eval "$(dircolors -b)"
      ''}
    '')

    ''
      real-which() {
        realpath $(which -a $1)
      }

      ${pkgs.ncurses}/bin/tabs -4 # set tab width to 4 spaces
    ''

    cfg.initExtra

    dynamicShellInit
  ];

  logoutExtra = ''
    [[ -e "$HOME/.lesshst" ]]             && rm -f "$HOME/.lesshst"
    [[ -e "$HOME/.xsession-errors.old" ]] && rm -f "$HOME/.xsession-errors.old"
    [[ -e "$HOME/.zcompdump" ]]           && rm -f "$HOME/.zcompdump"*

    ${pkgs.ncurses}/bin/clear

    ${cfg.logoutExtra}
  '';

  profileExtra = ''
    umask 022
  '';

  shellAliases = {
    ls = "ls --color=auto";
    la = "ls -AFv";
    l1 = "ls -AFh1v";
    ll = "ls -AFhlv";
    llr = "ll /nix/var/nix/gcroots/auto --color=always | grep result";

    cp = "cp -av";
    mv = "mv -v";
    rm = "rm -v";
    ln = "ln -v";

    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";

    sort-vn = "sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "......" = "cd ../../../../..";

    e = "nvim";

    bc = "bc -l";

    df = "df --human-readable --local --print-type";
    du = "du --human-readable --one-file-system --time --time-style=+'%Y-%m-%d' --total";

    rg = "rg --hidden --glob '!.git' --ignore-case --sort=path";

    pwgen = "pwgen -cns";
    pgen = "pwgen 30 1";

    tailf = "tail -f";

    tree = "tree -F --dirsfirst";
    treea = "tree -a";
    treei = "treea -I '.git|.idea'";
  }
  // (optionalAttrs (!config.custom.base.general.darwin) {
    open = "xdg-open";
  })
  // cfg.shellAliases
  // (optionalAttrs (dynamicShellInit != "") {
    refresh-shell = "source ${pkgs.writeText "refresh-shell" dynamicShellInit}";
  });

  dynamicShellInit = concatStringsSep "\n" (
    map
      (options:
        if (options.initExtra == "" && options.shellAliases == { })
        then ""
        else
          ''
            if ${options.condition}; then
              ${concatStringsSep "\n" (
                mapAttrsToList (k: v: "alias ${k}=${escapeShellArg v}") options.shellAliases
              )}

              ${options.initExtra}
            fi
          ''
      )
      cfg.dynamicShellInit
  );
in

{

  ###### interface

  options = {

    custom.programs.shell = {

      enable = mkEnableOption "basic shell config";

      envExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when setting up a shell.
        '';
      };

      initExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be executed when starting an interactive shell.
        '';
      };

      logoutExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when exiting a login shell.
        '';
      };

      loginExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when initializing a login shell.
        '';
      };

      shellAliases = mkOption {
        default = { };
        type = types.attrsOf types.str;
        example = { ll = "ls -l"; ".." = "cd .."; };
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
      };

      dynamicShellInit = mkOption {
        default = [ ];
        type = types.listOf dynamicShellInitModule;
        example = [
          {
            condition = "available composer";

            shellAliases = {
              cinstall = "composer install";
            };

            initExtra = ''
              # extra config
            '';
          }
        ];
        description = ''
          Specify dynamic shell init which has to be reloaded after environment change.

          Note: This only adds config and is not intended to cleanup after context switch
          when to defined conditions are no more true.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs = {
      bash = {
        inherit logoutExtra shellAliases;
        profileExtra = mkMerge [ profileExtra cfg.envExtra ];
        initExtra = mkMerge [ initExtra cfg.loginExtra ];
      };

      zsh = {
        inherit (cfg) envExtra loginExtra;
        inherit logoutExtra profileExtra shellAliases;
        initContent = mkMerge [
          (mkBefore ''
            available() {
              hash "$1" > /dev/null 2>&1
            }
          '')

          initExtra
        ];
      };
    };

  };

}
