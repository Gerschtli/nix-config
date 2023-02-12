{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.dunst;
in

{

  ###### interface

  options = {

    custom.services.dunst.enable = mkEnableOption "dunst config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.dunst = {
      enable = true;

      settings = {
        global = {
          font = "Monospace 11";

          # Allow a small subset of html markup:
          #   <b>bold</b>
          #   <i>italic</i>
          #   <s>strikethrough</s>
          #   <u>underline</u>
          #
          # For a complete reference see
          # <http://developer.gnome.org/pango/stable/PangoMarkupFormat.html>.
          # If markup is not allowed, those tags will be stripped out of the
          # message.
          markup = true;

          # The format of the message.  Possible variables are:
          #   %a  appname
          #   %s  summary
          #   %b  body
          #   %i  iconname (including its path)
          #   %I  iconname (without its path)
          #   %p  progress value if set ([  0%] to [100%]) or nothing
          # Markup is allowed
          format = ''<b>%s</b>\n%b'';

          # Sort messages by urgency.
          sort = true;

          # Show how many messages are currently hidden (because of geometry).
          indicate_hidden = true;

          # Alignment of message text.
          # Possible values are "left", "center" and "right".
          alignment = "right";

          # The frequency with wich text that is longer than the notification
          # window allows bounces back and forth.
          # This option conflicts with "word_wrap".
          # Set to 0 to disable.
          bounce_freq = 0;

          # Show age of message if message is older than show_age_threshold
          # seconds.
          # Set to -1 to disable.
          show_age_threshold = 60;

          # Split notifications into multiple lines if they don't fit into
          # geometry.
          word_wrap = true;

          # Ignore newlines '\n' in notifications.
          ignore_newline = false;

          width = 300;
          offset = "8x25";

          # Shrink window if it's smaller than the width.  Will be ignored if
          # width is 0.
          shrink = false;

          # The transparency of the window.  Range: [0; 100].
          # This option will only work if a compositing windowmanager is
          # present (e.g. xcompmgr, compiz, etc.).
          transparency = 0;

          # Don't remove messages, if the user is idle (no mouse or keyboard input)
          # for longer than idle_threshold seconds.
          # Set to 0 to disable.
          idle_threshold = 120;

          # Which monitor should the notifications be displayed on.
          monitor = 0;

          # Display notification on focused monitor.  Possible modes are:
          #   mouse: follow mouse pointer
          #   keyboard: follow window with keyboard focus
          #   none: don't follow anything
          #
          # "keyboard" needs a windowmanager that exports the
          # _NET_ACTIVE_WINDOW property.
          # This should be the case for almost all modern windowmanagers.
          #
          # If this option is set to mouse or keyboard, the monitor option
          # will be ignored.
          follow = "mouse";

          # Should a notification popped up from history be sticky or timeout
          # as if it would normally do.
          sticky_history = true;

          # Maximum amount of notifications kept in history
          history_length = 20;

          # Display indicators for URLs (U) and actions (A).
          show_indicators = true;

          # The height of a single line.  If the height is smaller than the
          # font height, it will get raised to the font height.
          # This adds empty space above and under the text.
          line_height = 0;

          # Draw a line of "separatpr_height" pixel height between two
          # notifications.
          # Set to 0 to disable.
          separator_height = 2;

          # Padding between text and separator.
          padding = 8;

          # Horizontal padding.
          horizontal_padding = 8;

          # Define a color for the separator.
          # possible values are:
          #  * auto: dunst tries to find a color fitting to the background;
          #  * foreground: use the same color as the foreground;
          #  * frame: use the same color as the frame;
          #  * anything else will be interpreted as a X color.
          separator_color = "frame";

          # Print a notification on startup.
          # This is mainly for error detection, since dbus (re-)starts dunst
          # automatically after a crash.
          startup_notification = false;

          # Align icons left/right/off
          icon_position = "off";

          frame_width = 3;
          frame_color = "#aaaaaa";
        };

        urgency_low = {
          foreground = "#778c7b";
          background = "#222222";
          timeout = 5;
        };

        urgency_normal = {
          foreground = "#778c7b";
          background = "#222222";
          timeout = 5;
        };

        urgency_critical = {
          background = "#990000";
          foreground = "#222222";
          timeout = 0;
        };
      };
    };

  };

}
