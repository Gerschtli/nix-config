{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.tmux;

  extraConfig = ''
    set-option -g allow-rename off
    set-option -g renumber-windows on

    set-option -g set-titles on
    set-option -g set-titles-string "#{pane_title}"

    # Set the height of the other panes (not the main pane) in the main-horizontal
    # layout. If this option is set to 0 (the default), it will have no effect. If
    # both the main-pane-height and other-pane-height options are set, the main pane
    # will grow taller to make the other panes the specified height, but will never
    # shrink to do so.
    set-window-option -g other-pane-height 10
    set-window-option -g other-pane-width 100

    # Bind key to command. By default (without -t) the primary key bindings are
    # modified (those normally activated with the prefix key); in this case, if -n
    # is specified, it is not necessary to use the prefix key, command is bound to
    # key alone. The -r flag indicates this key may repeat, see the repeat-time
    # option.
    # If -t is present, key is bound in key-table: the binding for command mode with
    # -c or for normal mode without. To view the default bindings and possible
    # commands, see the list-keys command
    unbind Up
    unbind Down
    unbind Left
    unbind Right

    unbind C-Up
    unbind C-Down
    unbind C-Left
    unbind C-Right

    bind-key Escape copy-mode

    bind-key A last-pane

    bind-key \; select-layout main-horizontal
    bind-key _ select-layout even-vertical
    bind-key M select-layout main-vertical
    bind-key N select-layout even-horizontal
    bind-key B select-layout tiled

    bind-key o select-pane -t :.+
    bind-key O select-pane -t :.-
    bind-key / display-panes \; select-pane -t :.

    bind-key 0   select-window -t :10
    bind-key F1  select-window -t :11
    bind-key F2  select-window -t :12
    bind-key F3  select-window -t :13
    bind-key F4  select-window -t :14
    bind-key F5  select-window -t :15
    bind-key F6  select-window -t :16
    bind-key F7  select-window -t :17
    bind-key F8  select-window -t :18
    bind-key F9  select-window -t :19
    bind-key F10 select-window -t :20
    bind-key F11 select-window -t :21
    bind-key F12 select-window -t :22

    bind-key : command-prompt

    bind -r C-h select-window -t :-
    bind -r C-l select-window -t :+

    bind e   send-keys -t :.- up C-m
    bind E   send-keys -t :.- C-c C-m up C-m
    bind C-E send-keys -t :.- X C-m up C-m

    bind Left swap-window -t :-
    bind Right swap-window -t :+

    # open new pane in same directory
    bind-key '"' split-window -c "#{pane_current_path}"
    bind-key %   split-window -h -c "#{pane_current_path}"
    bind-key c   new-window -c "#{pane_current_path}"


    ######################
    ### DESIGN CHANGES ###
    ######################

    # panes
    set -g pane-border-fg black
    set -g pane-active-border-fg brightred

    ## Status bar design
    # status line
    set -g status-justify left
    set -g status-bg default
    set -g status-fg colour12
    set -g status-interval 2

    # messaging
    set -g message-fg black
    set -g message-bg yellow
    set -g message-command-fg blue
    set -g message-command-bg black

    #window mode
    setw -g mode-bg colour6
    setw -g mode-fg colour0

    # window status
    setw -g window-status-format " #F#I:#W#F "
    setw -g window-status-current-format " #F#I:#W#F "
    setw -g window-status-format "#[fg=magenta]#[bg=black] #I #[bg=cyan]#[fg=colour8] #W "
    setw -g window-status-current-format "#[bg=brightmagenta]#[fg=colour8] #I #[fg=colour8]#[bg=colour14] #W "
    setw -g window-status-current-bg colour0
    setw -g window-status-current-fg colour11
    setw -g window-status-current-attr dim
    setw -g window-status-bg green
    setw -g window-status-fg black
    setw -g window-status-attr reverse

    # loud or quiet?
    set-option -g visual-activity off
    set-option -g visual-bell off
    set-option -g visual-silence off
    set-window-option -g monitor-activity off
    set-option -g bell-action none

    # The modes
    setw -g clock-mode-colour colour135
    setw -g mode-attr bold
    setw -g mode-fg colour196
    setw -g mode-bg colour238

    # The panes
    set -g pane-border-bg colour235
    set -g pane-border-fg colour238
    set -g pane-active-border-bg colour236
    set -g pane-active-border-fg colour51

    # The statusbar
    set -g status-position bottom
    set -g status-bg colour234
    set -g status-fg colour137
    set -g status-attr dim
    set -g status-left '#[fg=colour249,bg=colour236] #(whoami)@#[fg=colour231,bold]#H #[fg=colour137,bg=colour234]  '
    set -g status-right '#[fg=colour233,bg=colour245] %d.%m.%Y #[fg=colour233,bg=colour250] %H:%M '
    set -g status-right-length 50
    set -g status-left-length 20

    setw -g window-status-current-fg colour81
    setw -g window-status-current-bg colour238
    setw -g window-status-current-attr bold
    setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '

    setw -g window-status-fg colour138
    setw -g window-status-bg colour235
    setw -g window-status-attr none
    setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '

    setw -g window-status-bell-attr bold
    setw -g window-status-bell-fg colour255
    setw -g window-status-bell-bg colour1

    # The messages
    set -g message-attr bold
    set -g message-fg colour232
    set -g message-bg colour166
  '';
in

{

  ###### interface

  options = {

    custom.tmux.enable = mkEnableOption "tmux config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.shell.shellAliases.tmux = "tmux -2";

    home.packages = [
      (pkgs.writeScriptBin "tprofile" ''
        #!${pkgs.runtimeShell} -e

        exec ${../files/tmux/bin/tprofile} ${../files/tmux/profiles} $@
      '')

      (pkgs.writeTextFile {
        name = "_tprofile";
        destination = "/share/zsh/site-functions/_tprofile";
        text = ''
          #compdef tprofile

          _directory_writable() {
            unset ROOT
            source "$1"
            [[ -z "$ROOT" || -w "$ROOT" ]]
          }

          LIST=()
          PATH_TO_CONF_DIR="${../files/tmux/profiles}"

          prefix="${../files/tmux/profiles}/"
          suffix=".sh"

          for file in "$prefix"*"$suffix"; do
            if _directory_writable "$file"; then
              LIST+=("''${''${file#$prefix}//$suffix}")
            fi
          done

          for dir in ${config.home.homeDirectory}/projects/* ${config.home.homeDirectory}/projects/pveu/*; do
            LIST+=("$(basename "$dir")")
          done

          _arguments \
            "1:profiles:($LIST)" \
            "*:options:(--only-fetch --no-lorri-update)"
        '';
      })
    ];

    programs.tmux = {
      inherit extraConfig;

      enable = true;

      terminal = "screen-256color";
      baseIndex = 1;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      shortcut = "a";
      clock24 = true;
    };

  };

}
