{ pkgs, lib, config, inputs, ... }@configArgs:
let
  commonConfig = config.lib.custom.commonConfig configArgs;
in

{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  users.users.tobiashapp.home = "/Users/tobiashapp";
  services.nix-daemon.enable = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = false;
  programs.zsh.enableBashCompletion = false;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

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

  fonts.fontDir.enable = true;
  fonts.fonts = [
    (pkgs.nerdfonts.override { fonts = [ "UbuntuMono" ]; })
  ];

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

  security.pam.enableSudoTouchIdAuth = true;

  services.yabai.enable = true;
  services.yabai.config = {
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
  services.yabai.extraConfig = ''
    yabai -m rule --add app='Calculator' manage=off
    yabai -m rule --add app='System Settings' manage=off
  '';
  services.skhd.enable = true;
  services.skhd.skhdConfig = ''
    # -- Changing Window Focus --

    # change window focus within space
    alt - j : yabai -m window --focus south
    alt - k : yabai -m window --focus north
    alt - h : yabai -m window --focus west
    alt - l : yabai -m window --focus east

    #change focus between external displays (left and right)
    alt - s: yabai -m display --focus west
    alt - g: yabai -m display --focus east

    # -- Modifying the Layout --

    # rotate layout clockwise
    shift + alt - r : yabai -m space --rotate 270

    # flip along y-axis
    shift + alt - y : yabai -m space --mirror y-axis

    # flip along x-axis
    shift + alt - x : yabai -m space --mirror x-axis

    # toggle window float
    shift + alt - t : yabai -m window --toggle float --grid 4:4:1:1:2:2


    # -- Modifying Window Size --

    # maximize a window
    shift + alt - m : yabai -m window --toggle zoom-fullscreen

    # balance out tree of windows (resize to occupy same area)
    shift + alt - e : yabai -m space --balance

    # -- Moving Windows Around --

    # swap windows
    shift + alt - j : yabai -m window --swap south
    shift + alt - k : yabai -m window --swap north
    shift + alt - h : yabai -m window --swap west
    shift + alt - l : yabai -m window --swap east

    # move window and split
    ctrl + alt - j : yabai -m window --warp south
    ctrl + alt - k : yabai -m window --warp north
    ctrl + alt - h : yabai -m window --warp west
    ctrl + alt - l : yabai -m window --warp east

    # move window to display left and right
    shift + alt - s : yabai -m window --display west; yabai -m display --focus west;
    shift + alt - g : yabai -m window --display east; yabai -m display --focus east;


    # move window to prev and next space
    shift + alt - p : yabai -m window --space prev;
    shift + alt - n : yabai -m window --space next;

    # move window to space #
    shift + alt - 1 : yabai -m window --space 1;
    shift + alt - 2 : yabai -m window --space 2;
    shift + alt - 3 : yabai -m window --space 3;
    shift + alt - 4 : yabai -m window --space 4;
    shift + alt - 5 : yabai -m window --space 5;
    shift + alt - 6 : yabai -m window --space 6;
    shift + alt - 7 : yabai -m window --space 7;

    # -- Starting/Stopping/Restarting Yabai --

    # stop/start/restart yabai
    ctrl + alt - q : launchctl stop org.nixos.yabai
    ctrl + alt - s : launchctl start org.nixos.yabai
    ctrl + alt - r : launchctl stop org.nixos.yabai; launchctl start org.nixos.yabai
  '';

  # TODO
  # cachix-agent
  # nix-darwin CI
  # lorri
  # Hidden bar
  # Alttab

  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  system.defaults.NSGlobalDomain.KeyRepeat = 3;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false; # disable natural scrolling
  system.defaults.NSGlobalDomain.NSScrollAnimationEnabled = false;
  system.defaults.dock.autohide = true;
  system.defaults.dock.tilesize = 48;
  system.defaults.finder.FXPreferredViewStyle = "Nlsv"; # list view
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.ShowStatusBar = true;

  # manually
  # install chrome, intellij, iterm2, docker, vscode
  # iterm2 set UbuntuMono font, size 13, h 85, v 115, solarized dark, window size
  # disable keyboard shortcuts for "Input Sources" in system settings
  # enable keyboard shortcuts for Mission Control to switch to desktops
  # (A11y > Desktop > Enable Reduce Motion)
  # Desktop & Dock > Mission Control > Disable "Automatically rearrange Spaces based on most recent use

}
