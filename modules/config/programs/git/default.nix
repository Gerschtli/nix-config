{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.git;

  externGitAlias = alias: "!${alias}";

  ignoreList = map
    builtins.readFile
    (config.lib.custom.getFileList ./gitignores);

  commitMsgTemplate = ''

    # (If applied, this commit will...) <subject> (Max 50 char)
    # |<----  Using a Maximum Of 50 Characters  ---->|


    # Explain why this change is being made
    # |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|


    # Provide links or keys to any relevant tickets, articles or other resources
    # Example: Github issue #23


    # --- COMMIT END ---
    # Remember to
    #    Capitalize the subject line
    #    Use the imperative mood in the subject line
    #    Do not end the subject line with a period
    #    Separate subject from body with a blank line
    #    Use the body to explain what and why vs. how
    #    Can use multiple lines with "-" for bullet points in body
  '';

  extractName = path: removeSuffix ".sh" (baseNameOf path);
  hooksPathPackages = with pkgs; [
    findutils
    gitAndTools.git-lfs
    gitAndTools.gitFull
    gnugrep
    nixpkgs-fmt
    openssh
  ];

  hooksIncludes = map
    (filename:
      let file = ./includes + "/${filename}"; in
      config.lib.custom.mkScriptPlain
        "hooks-include-${extractName file}"
        file
        hooksPathPackages
        { hooksLib = ./lib.hooks.sh; }
    )
    (builtins.attrNames (builtins.readDir ./includes));

  hooksPath = pkgs.linkFarm "git-hooks" (
    map
      (file:
        let name = extractName file; in
        {
          inherit name;
          path = config.lib.custom.mkScriptPlain
            "hooks-${name}"
            file
            hooksPathPackages
            { hooksLib = ./lib.hooks.sh; includes = hooksIncludes; };
        })
      [
        ./post-checkout.sh
        ./post-commit.sh
        ./post-merge.sh
        ./post-rewrite.sh
        ./pre-commit.sh
        ./pre-push.sh
      ]
  );

  writeFile = name: content: toString (pkgs.writeText name content);
in

{

  ###### interface

  options = {

    custom.programs.git.enable = mkEnableOption "git config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [ pkgs.gitAndTools.tig ];

    programs.git = {
      enable = true;

      userName = "Tobias Happ";
      userEmail = "tobias.happ@gmx.de";

      ignores = ignoreList;
      lfs.enable = true;

      aliases = {
        ad = "add --all --ignore-errors --";
        ba = "branch -a --verbose";
        bc = "checkout -b";
        bd = "branch --verbose --delete";
        bdd = "branch --verbose -D";
        ca = "commit -q --branch --status --verbose --amend";
        cl = externGitAlias "git clone --recursive --progress";
        cm = "commit --branch --status --verbose";
        cn = externGitAlias ''git reflog expire --all && git fsck --unreachable --full && git prune && \
          git gc --aggressive --quiet && git repack -Adq && git prune-packed --quiet'';
        co = "checkout";
        fe = "fetch --progress";
        fm = externGitAlias "git fe --all && git fe --all --tags";
        lg = "log --stat";
        lp = "log -10 --patch-with-stat";
        ma = "merge --abort";
        me = "merge --stat --summary";
        mm = externGitAlias "git me origin/$(git branch-name)";
        pd = "push --no-verify --delete --progress origin";
        pf = externGitAlias "git ph --force-with-lease origin $(git branch-name)";
        ph = "push --progress --tags --set-upstream";
        pu = externGitAlias "for i in $(git remote); do git ph $i $(git branch-name); done";
        ra = "rebase --abort";
        rc = "rebase --continue";
        re = "reset";
        rh = "reset --hard";
        rp = "rebase --skip";
        rs = "reset --soft";
        rv = "remote --verbose";
        sa = "stash push";
        sau = "stash push --include-untracked";
        sc = "stash clear";
        sl = "stash list";
        sm = "submodule";
        so = "stash pop";
        st = "status";
        sw = "stash show";

        cma = externGitAlias "git co master && git rebase origin/master";
        mma = "merge origin/master";
        rma = "rebase origin/master";
        rup = "rebase upstream/master";

        aliases = ''config --get-regexp "^alias"'';

        bclean = externGitAlias ''git for-each-ref --format "%(refname:short)" refs/heads |
          ${pkgs.gnugrep}/bin/grep -Ev "master|$(git branch-name)" | ${pkgs.findutils}/bin/xargs git bd'';

        branch-name = externGitAlias ''git for-each-ref --format="%(refname:short)" $(git symbolic-ref HEAD)'';
        total-clean = externGitAlias "git co -f && git clean -dfx && git clean -dfX";

        disable-upstream-push = "remote set-url upstream --push DISABLED";
        initial-commit = externGitAlias "git init && ${pkgs.coreutils}/bin/touch .gitignore && git add .gitignore && \
          git commit -m 'Initial commit'";
        set-upstream = externGitAlias "git branch --set-upstream-to=origin/$(git branch-name) $(git branch-name)";
      };

      extraConfig = {
        add.ignore-errors = true;

        advice = {
          detachedHead = false;
          pushNonFastForward = false;
          statusHints = false;
        };

        apply = {
          ignorewhitespace = "change";
          whitespace = "nowarn";
        };

        branch = {
          autoSetupMerge = "always";
          autoSetupRebase = "always";
        };

        clean.requireForce = true;

        color = {
          branch = {
            current = "green normal bold";
            local = "yellow normal bold";
            plain = "white normal bold";
            remote = "red normal bold";
          };

          diff = "auto";
          grep = "auto";
          interactive = "auto";
          showbranch = "auto";

          status = {
            added = "green normal bold";
            updated = "green normal bold";
            changed = "yellow normal bold";
            nobranch = "red white blink";
            untracked = "red normal bold";
          };
        };

        commit = {
          status = true;
          template = writeFile "commit.msg" commitMsgTemplate;
        };

        core = {
          compression = 9;
          eol = "lf";
          editor = "${config.custom.programs.neovim.finalPackage}/bin/nvim";
          hooksPath = toString hooksPath;
          loosecompression = 9;
          preloadindex = true;
        };

        credential.helper = "cache";

        diff = {
          mnemonicprefix = true;
          renames = "copies";
          tool = "nvim";

          gpg.textconv = "${pkgs.gnupg}/bin/gpg --use-agent -q --batch --decrypt";
        };

        difftool = {
          prompt = true;

          nvim.cmd = "${config.custom.programs.neovim.finalPackage}/bin/nvim -d \"$LOCAL\" \"$REMOTE\"";
        };

        fetch = {
          prune = true;
          recurseSubmodules = true;
        };

        grep.lineNumber = true;

        help = {
          autocorrect = 0;
          format = "man";
        };

        i18n.logOutputEncoding = "utf8";

        interactive.singlekey = false;

        log.date = "iso";

        merge = {
          log = true;
          tool = "nvim";
          verbosity = 5;
        };

        mergetool = {
          keepBackup = false;
          prompt = true;
          writeToTemp = true;

          nvim.cmd = "${config.custom.programs.neovim.finalPackage}/bin/nvim -d \"$LOCAL\" \"$REMOTE\" \"$MERGED\" -c 'wincmd w' -c 'wincmd J'";
        };

        pack.compression = 9;

        pretty.graph = "format:%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset";

        pull.ff = "only";

        rebase = {
          autoSquash = true;
          autoStash = true;
          stat = true;
        };

        rerere.enabled = 1;

        status = {
          relativePaths = false;
          showUntrackedFiles = "all";
        };

        tag.sort = "version:refname"; # sort alpha-numerically

        tig = {
          commit-order = "topo";
          horizontal-scroll = "95%";
          ignore-case = "yes";
          line-graphics = "utf-8";
          mouse = "yes";
          mouse-scroll = 5;
          refresh-interval = 300;
          refresh-mode = "periodic";
          split-view-height = "75%";
          tab-size = 4;
          vertical-split = false;

          # View settings
          main-view = "line-number:yes,interval=5 id:no date:default author:full,width=15 commit-title:yes,graph=yes,refs=yes,overflow=no";
          blame-view = "line-number:yes,interval=5 date:default author:full,width=15 file-name:auto id:yes,color text";

          # Pager based views
          blob-view = "line-number:yes,interval=5 text";
          diff-view = "line-number:yes,interval=5 text:yes,commit-title-overflow=no";
          log-view = "line-number:yes,interval=5 text";
          pager-view = "line-number:yes,interval=5 text";
          stage-view = "line-number:yes,interval=5 text";

          color = {
            default = "default default normal";
            cursor = "white blue bold";
            title-blur = "blue default";
            title-focus = "blue default bold";
          };
        };
      };
    };

  };

}
