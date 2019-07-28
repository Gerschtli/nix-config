{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.git;

  externGitAlias = alias: "!\"${builtins.replaceStrings [''"''] [''\"''] alias}\"";

  ignoreList = [

    ''
      # Created by https://www.gitignore.io/api/intellij+all

      ### Intellij+all ###
      # Covers JetBrains IDEs: IntelliJ, RubyMine, PhpStorm, AppCode, PyCharm, CLion, Android Studio and Webstorm
      # Reference: https://intellij-support.jetbrains.com/hc/en-us/articles/206544839

      # User-specific stuff:
      .idea/**/workspace.xml
      .idea/**/tasks.xml
      .idea/dictionaries

      # Sensitive or high-churn files:
      .idea/**/dataSources/
      .idea/**/dataSources.ids
      .idea/**/dataSources.xml
      .idea/**/dataSources.local.xml
      .idea/**/sqlDataSources.xml
      .idea/**/dynamic.xml
      .idea/**/uiDesigner.xml

      # Gradle:
      .idea/**/gradle.xml
      .idea/**/libraries

      # CMake
      cmake-build-debug/

      # Mongo Explorer plugin:
      .idea/**/mongoSettings.xml

      ## File-based project format:
      *.iws

      ## Plugin-specific files:

      # IntelliJ
      /out/

      # mpeltonen/sbt-idea plugin
      .idea_modules/

      # JIRA plugin
      atlassian-ide-plugin.xml

      # Cursive Clojure plugin
      .idea/replstate.xml

      # Ruby plugin and RubyMine
      /.rakeTasks

      # Crashlytics plugin (for Android Studio and IntelliJ)
      com_crashlytics_export_strings.xml
      crashlytics.properties
      crashlytics-build.properties
      fabric.properties

      ### Intellij+all Patch ###
      # Ignores the whole .idea folder and all .iml files
      # See https://github.com/joeblau/gitignore.io/issues/186 and https://github.com/joeblau/gitignore.io/issues/360

      .idea/

      # Reason: https://github.com/joeblau/gitignore.io/issues/186#issuecomment-249601023

      *.iml
      modules.xml
      .idea/misc.xml
      *.ip
    ''

    ''
      # Created by https://www.gitignore.io/api/linux

      ### Linux ###
      *~

      # temporary files which can be created if a process still has a handle open of a deleted file
      .fuse_hidden*

      # KDE directory preferences
      .directory

      # Linux trash folder which might appear on any partition or disk
      .Trash-*

      # .nfs files are created when an open file is removed but is still being accessed
      .nfs*
    ''

  ];

  commitMsgTemplate = link: ''

    # ^ (If applied, this commit will...) <subject>

    # Explain why this change is being made


    # Provide links or keys to any relevant tickets, articles or other resources
    # Example: Github issue #23
    ${link}


    # --- COMMIT END ---
    # Remember to
    #    Capitalize the subject line
    #    Use the imperative mood in the subject line
    #    Do not end the subject line with a period
    #    Separate subject from body with a blank line
    #    Use the body to explain what and why vs. how
    #    Can use multiple lines with "-" for bullet points in body
  '';

  writeFile = name: content: "${pkgs.writeText name content}";
in

{

  ###### interface

  options = {

    custom.git.enable = mkEnableOption "git config";

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
        bnc = externGitAlias ''git branch-name | xclip -selection clipboard && echo "Branch name copied to clipboard!"'';
        ca = "commit -q --branch --status --verbose --amend";
        cf = "checkout --quiet --force";
        cl = externGitAlias "git clone --recursive --progress";
        cm = "commit --branch --status --verbose";
        cn = externGitAlias ''git reflog expire --all && git fsck --unreachable --full && git prune && \
          git gc --aggressive --quiet && git repack -Adq && git prune-packed --quiet'';
        co = "checkout";
        fa = externGitAlias "git fe --all && git fe --all --tags";
        fe = "fetch --progress";
        fm = externGitAlias "git fe && git fe --tags";
        gi = externGitAlias "git gr --ignore-case";
        gr = "grep --line-number --break --heading";
        lg = "log --stat";
        lm = "log --merges --stat";
        lp = "log -10 --patch-with-stat";
        ma = "merge --abort";
        me = "merge --stat --summary";
        mm = externGitAlias "git me origin/$(git branch-name)";
        mt = "mergetool --no-prompt";
        pd = "push --no-verify --delete --progress origin";
        ph = "push --progress --tags --set-upstream";
        pu = externGitAlias "for i in $(git remote); do git ph \${i} $(git branch-name); done";
        pn = externGitAlias "for i in $(git remote); do git ph --no-verify \${i} $(git branch-name); done";
        ra = "rebase --abort";
        rc = "rebase --continue";
        re = "reset";
        rh = "reset --hard";
        rp = "rebase --skip";
        rs = "reset --soft";
        rv = "remote --verbose";
        sa = "stash save";
        saa = "stash save --all";
        sc = "stash clear";
        sl = "stash list";
        sm = "submodule";
        so = "stash pop";
        st = "status";
        sw = "stash show";
        tl = externGitAlias "git tag | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | tail -n 5";

        cma = externGitAlias "git co master && git rebase -n origin/master";
        mma = "merge origin/master";

        aliases = ''config --get-regexp "^alias"'';

        bclean = externGitAlias ''git for-each-ref --format "%(refname:short)" refs/heads | \
          grep -Ev "master|$(git branch-name)" | xargs git bd'';

        branch-name = externGitAlias ''git for-each-ref --format="%(refname:short)" $(git symbolic-ref HEAD)'';
        total-clean = externGitAlias "git co -f && git clean -dfx && git clean -dfX";

        set-upstream = externGitAlias "git branch --set-upstream-to=origin/$(git branch-name) $(git branch-name)";
      };

      extraConfig = {
        add.ignore-errors = true;

        advice = {
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
          editor = "nvim"; # TODO: replace with path
          hooksPath = "${../files/git/hooks}";
          loosecompression = 9;
          preloadindex = true;
        };

        credential.helper = "cache";

        diff = {
          mnemonicprefix = true;
          renames = "copies";
          tool = "vimdiff"; # TODO: configure and replace with path

          gpg.textconv = "gpg --use-agent -q --batch --decrypt"; # TODO: replace with path
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
          tool = "vscode"; # TODO: configure
          verbosity = 5;
        };

        mergetool = {
          keepBackup = false;
          writeToTemp = true;

          subl = {
            cmd = "$(subl --get-executable) -w $MERGED"; # TODO: replace with path
            trustExitCode = false;
          };

          vscode.cmd = "code --wait $MERGED"; # TODO: replace with path
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

      includes = [
        {
          condition = "gitdir:~/projects/pveu/*";

          contents = {
            commit.template = writeFile "commit.msg" (commitMsgTemplate "BRANCHNAME");

            core.excludesfile =
              let
                ignoreListPveu = ignoreList ++ [ ".envrc" "shell.nix" ];
                content = concatStringsSep "\n" ignoreListPveu + "\n";
              in
                writeFile "gitignore" content;

            user.email = "th@preisvergleich.eu";
          };
        }
      ];
    };

  };

}
