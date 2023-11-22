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

  # TODO
  # cachix-agent
  # nix-darwin CI
  # yabai
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

}
