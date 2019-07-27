{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.shell;

  initExtra = ''
    eval "$(dircolors -b)"
  '';

  logoutExtra = ''
    [[ -e "$HOME/.lesshst" ]]             && rm -f "$HOME/.lesshst"
    [[ -e "$HOME/.xsession-errors.old" ]] && rm -f "$HOME/.xsession-errors.old"
    [[ -e "$HOME/.zcompdump" ]]           && rm -f "$HOME/.zcompdump"*

    ${pkgs.ncurses}/bin/clear
  '';

  profileExtra = ''
    umask 022
  '';

  shellAliases = {
    ls = "ls --color=auto";
    la = "ls -AFv";
    ll = "ls -AFhlv";

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

    e = "$EDITOR";

    bc = "bc -l";

    df = "df -h";

    rg = "rg --ignore-case --sort=path";

    open = "xdg-open";

    pwgen = "pwgen -cny";
    pwgens = "pwgen -s";

    tree = "tree -F --dirsfirst";
    treea = "tree -a";
  } // cfg.shellAliases;
in

{

  ###### interface

  options = {

    custom.shell = {

      enable = mkEnableOption "basic shell config";

      shellAliases = mkOption {
        default = {};
        type = types.attrsOf types.str;
        example = { ll = "ls -l"; ".." = "cd .."; };
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs = {
      bash = {
        inherit initExtra logoutExtra profileExtra shellAliases;
      };

      zsh = {
        inherit initExtra logoutExtra profileExtra shellAliases;
      };
    };

  };

}
