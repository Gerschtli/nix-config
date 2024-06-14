{ config, lib, pkgs, ... }:

let
  inherit (builtins)
    attrValues
    readDir
    ;
  inherit (lib)
    attrNames
    concatStringsSep
    filesystem
    flip
    mkEnableOption
    mkIf
    mkMerge
    readFile
    removeSuffix
    ;

  cfg = config.custom.programs.git;

  externGitAlias = alias: "!${alias}";

  ignoreList = map
    readFile
    (filesystem.listFilesRecursive ./gitignores);

  commitMsgTemplate = footer: ''

    # (If applied, this commit will...) <subject> (Max 50 char)
    # |<----  Using a Maximum Of 50 Characters  ---->|


    # Explain why this change is being made
    # |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|


    # Provide links or keys to any relevant tickets, articles or other resources
    # Example: Github issue #23
    ${footer}
  '';

  extractName = path: removeSuffix ".sh" (baseNameOf path);
  hooksPathPackages = with pkgs; [
    findutils
    git
    gnugrep
    gnused
    nix
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
    (attrNames (readDir ./includes));

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
        ./prepare-commit-msg.sh
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

    home.packages = [
      pkgs.git-absorb
      pkgs.tig
      (
        config.lib.custom.mkScript
          "git-initial-commit"
          ./git-initial-commit.sh
          [ pkgs.coreutils pkgs.git ]
          { }
      )
    ];

    programs.git = {
      enable = true;

      userName = "Tobias Happ";
      userEmail = "tobias.happ@gmx.de";

      ignores = ignoreList;

      aliases = {
        ad = "add --all --ignore-errors --";
        ba = "branch -a --verbose";
        bc = "switch --create";
        bd = "branch --verbose --delete";
        bdd = "branch --verbose -D";
        ca = "commit -q --branch --status --verbose --amend";
        cl = externGitAlias "git clone --recursive --progress";
        cm = "commit --branch --status --verbose";
        cn = externGitAlias ''git reflog expire --all && git fsck --unreachable --full && git prune && \
          git gc --aggressive --quiet && git repack -Adq && git prune-packed --quiet'';
        df = "diff";
        di = "diff --ignore-all-space";
        ds = "diff --staged";
        dsi = "diff --staged --ignore-all-space";
        fe = "fetch --progress";
        fm = externGitAlias "git fe --all && git fe --all --tags";
        lg = "log --stat";
        lp = "log -10 --patch-with-stat";
        ma = "merge --abort";
        me = "merge --stat --summary";
        mm = externGitAlias "git me origin/$(git branch-name)";
        pd = "push --no-verify --delete --progress origin";
        pf = externGitAlias "git ph --force-with-lease origin $(git branch-name)";
        pnf = externGitAlias "git pf --no-verify";
        ph = "push --progress --tags --set-upstream";
        pu = externGitAlias "for i in $(git remote); do git ph $i $(git branch-name); done";
        pn = externGitAlias "for i in $(git remote); do git ph --no-verify $i $(git branch-name); done";
        ra = "rebase --abort";
        rc = "rebase --continue";
        re = "reset";
        rh = "reset --hard";
        ri = "rebase --interactive";
        rp = "rebase --skip";
        rs = "reset --soft";
        rt = "restore";
        rv = "remote --verbose";
        sa = "stash push";
        sau = "stash push --include-untracked";
        sc = "stash clear";
        sl = "stash list";
        so = "stash pop";
        sp = "stash show --patch";
        st = "status";
        sw = "switch";
        sd = "switch --detach";
        tl = "tag --list -n";

        mma = externGitAlias "git merge origin/$(git default-branch)";
        rde = externGitAlias "git rebase origin/develop";
        rma = externGitAlias "git rebase origin/$(git default-branch)";
        rup = externGitAlias "git rebase upstream/$(git default-branch)";
        sde = externGitAlias "git switch develop && git rebase origin/develop";
        sma = externGitAlias "git switch $(git default-branch) && git rebase origin/$(git default-branch)";

        aliases = ''config --get-regexp "^alias"'';

        bclean = externGitAlias ''git for-each-ref --format "%(refname:short)" refs/heads |
          ${pkgs.gnugrep}/bin/grep -Ev "$(git default-branch)|$(git branch-name)" | ${pkgs.findutils}/bin/xargs git bd'';

        branch-name = "branch --show-current";
        total-clean = externGitAlias "git co -f && git clean -dfx && git clean -dfX";

        disable-upstream-push = "remote set-url upstream --push DISABLED";
        set-upstream = externGitAlias "git branch --set-upstream-to=origin/$(git branch-name) $(git branch-name)";
        default-branch = externGitAlias "git symbolic-ref refs/remotes/origin/HEAD | ${pkgs.gnused}/bin/sed 's@^refs/remotes/origin/@@'";
      };

      extraConfig = {
        absorb.oneFixupPerCommit = true;

        add.ignore-errors = true;

        advice = {
          detachedHead = false;
          forceDeleteBranch = false;
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
          template = writeFile "commit.msg" (commitMsgTemplate "");
        };

        core = {
          compression = 9;
          eol = "lf";
          editor = "${config.custom.programs.neovim.finalPackage}/bin/nvim";
          hooksPath = toString hooksPath;
          loosecompression = 9;
          pager = "${pkgs.less}/bin/less -x1,5"; # set tab width to 4 starting at offset of 1 to cope with diff format
          preloadindex = true;
        };

        credential.helper = "cache";

        diff = {
          mnemonicprefix = true;
          renames = "copies";
          tool = "nvim";

          age.textconv = toString (
            config.lib.custom.mkScriptPlain
              "age-textconv"
              ./age-textconv.sh
              [ pkgs.age ]
              { HOME = config.home.homeDirectory; }
          );

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

        init.defaultBranch = "main";

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
          updateRefs = true;
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

          # hide prefetch refs
          reference-format = "hide:other";

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

      includes = flip map (attrValues config.custom.misc.work) (work: {

        condition = "gitdir:~/projects/${work.directory}/";

        contents = mkMerge [

          {
            core.excludesfile =
              let
                ignoreListWork = ignoreList ++ [ ".envrc" "shell.nix" ];
                content = concatStringsSep "\n" ignoreListWork + "\n";
              in
              writeFile "gitignore" content;
          }

          (mkIf (work.name == "randstad") {
            user.email = "tobias.happ@randstaddigital.com";
          })

          (mkIf (work.name == "randstad-db") {
            alias.bcf = externGitAlias (
              config.lib.custom.mkScriptPlain
                "git-alias-bcf"
                ./git-alias-bcf.sh
                [ pkgs.git ]
                { }
            );

            commit.template = writeFile "commit.msg" (commitMsgTemplate "DB_FOOTER");

            user.email = "tobias.happ-extern@deutschebahn.com";

            # signing
            commit.gpgsign = true;
            gpg.format = "ssh";
            user.signingKey = "${config.home.homeDirectory}/.ssh/keys/id_ed25519.db.pub";

          })

        ];

      });
    };
  };

}
