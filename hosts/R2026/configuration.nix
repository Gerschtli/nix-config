{ config, lib, pkgs, inputs, ... }@configArgs:

let
  commonConfig = config.lib.custom.commonConfig configArgs;
in

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  fonts = {
    fontDir.enable = true;

    fonts = [ (pkgs.nerdfonts.override { fonts = [ "UbuntuMono" ]; }) ];
  };

  home-manager = {
    inherit (commonConfig.homeManager.baseConfig)
      backupFileExtension
      extraSpecialArgs
      sharedModules
      useGlobalPkgs
      useUserPackages
      ;

    users.tobiashapp = commonConfig.homeManager.userConfig "R2026" "tobiashapp";
  };

  nix = {
    settings = {
      inherit (commonConfig.nix.settings)
        experimental-features
        flake-registry
        log-lines
        substituters
        trusted-public-keys
        ;

      trusted-users = [ config.users.users.tobiashapp.name ];
    };

    inherit (commonConfig.nix)
      nixPath
      package
      registry
      ;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
  };

  security.pam.enableSudoTouchIdAuth = true;

  services = {
    nix-daemon.enable = true;

    yabai = {
      enable = true;
      config = {
        layout = "bsp"; # binary spaced partition
        focus_follows_mouse = "autoraise";
        window_placement = "second_child";

        # modifier for clicking and dragging with mouse
        mouse_modifier = "alt";
        # set modifier + left-click drag to move window
        mouse_action1 = "move";
        # set modifier + right-click drag to resize window
        mouse_action2 = "resize";

        # when window is dropped in center of another window, swap them (on edges it will split it)
        mouse_drop_action = "swap";
      };
      extraConfig = ''
        yabai -m rule --add app='Calculator' manage=off
        yabai -m rule --add app='System Settings' manage=off
      '';
    };

    skhd = {
      enable = true;
      skhdConfig = ''
        # -- Changing Window Focus --

        # change window focus within space
        ctrl - j : yabai -m window --focus south
        ctrl - k : yabai -m window --focus north
        ctrl - h : yabai -m window --focus west
        ctrl - l : yabai -m window --focus east

        #change focus between external displays (left and right)
        ctrl - s: yabai -m display --focus west
        ctrl - g: yabai -m display --focus east

        # -- Modifying the Layout --

        # rotate layout clockwise
        ctrl + shift - r : yabai -m space --rotate 270

        # flip along y-axis
        ctrl + shift - y : yabai -m space --mirror y-axis

        # flip along x-axis
        ctrl + shift - x : yabai -m space --mirror x-axis

        # toggle window float
        ctrl + shift - t : yabai -m window --toggle float --grid 4:4:1:1:2:2


        # -- Modifying Window Size --

        # maximize a window
        ctrl + shift - m : yabai -m window --toggle zoom-fullscreen

        # balance out tree of windows (resize to occupy same area)
        ctrl + shift - e : yabai -m space --balance

        # -- Moving Windows Around --

        # swap windows
        ctrl + shift - j : yabai -m window --swap south
        ctrl + shift - k : yabai -m window --swap north
        ctrl + shift - h : yabai -m window --swap west
        ctrl + shift - l : yabai -m window --swap east

        # move window and split
        ctrl + alt - j : yabai -m window --warp south
        ctrl + alt - k : yabai -m window --warp north
        ctrl + alt - h : yabai -m window --warp west
        ctrl + alt - l : yabai -m window --warp east

        # move window to display left and right
        ctrl + shift - s : yabai -m window --display west; yabai -m display --focus west;
        ctrl + shift - g : yabai -m window --display east; yabai -m display --focus east;


        # move window to prev and next space
        ctrl + shift - p : yabai -m window --space prev;
        ctrl + shift - n : yabai -m window --space next;

        # move window to space #
        ctrl + shift - 1 : yabai -m window --space 1;
        ctrl + shift - 2 : yabai -m window --space 2;
        ctrl + shift - 3 : yabai -m window --space 3;
        ctrl + shift - 4 : yabai -m window --space 4;
        ctrl + shift - 5 : yabai -m window --space 5;
        ctrl + shift - 6 : yabai -m window --space 6;
        ctrl + shift - 7 : yabai -m window --space 7;

        # -- Starting/Stopping/Restarting Yabai --

        # stop/start/restart yabai
        ctrl + alt - q : launchctl stop org.nixos.yabai
        ctrl + alt - s : launchctl start org.nixos.yabai
        ctrl + alt - r : launchctl stop org.nixos.yabai; launchctl start org.nixos.yabai
      '';
    };
  };

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 25;
        KeyRepeat = 3;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.swipescrolldirection" = false; # disable natural scrolling
        NSScrollAnimationEnabled = false;
      };
      dock = {
        autohide = true;
        tilesize = 48;
      };
      finder = {
        FXPreferredViewStyle = "Nlsv"; # list view
        ShowPathbar = true;
        ShowStatusBar = true;
      };
    };
  };

  users.users.tobiashapp.home = "/Users/tobiashapp";

  # TODO
  # cachix-agent
  # nix-darwin CI
  # lorri
  # Hidden bar
  # Alttab

  # manually
  # install chrome, intellij, iterm2, docker, vscode
  # iterm2 set UbuntuMono font, size 13, h 85, v 115, solarized dark, window size
  # disable keyboard shortcuts for "Input Sources" in system settings
  # enable keyboard shortcuts for Mission Control to switch to desktops
  # (A11y > Desktop > Enable Reduce Motion)
  # Desktop & Dock > Mission Control > Disable "Automatically rearrange Spaces based on most recent use

}
