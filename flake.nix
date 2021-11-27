{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # commit before jdk15 drop
    # https://github.com/NixOS/nixpkgs/commit/9dde9d8b9ee4b7a4dfbb0ab1204d9f6f4a188360
    nixpkgs-for-jdk15.url = "github:NixOS/nixpkgs/df175b7f61d852dc599fe248b1a8666c312457bd";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-cli = {
      url = "github:cole-h/agenix-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeage = {
      # url = "github:jordanisaacs/homeage";
      url = "github:Gerschtli/homeage/support-script";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dmenu = {
      url = "github:Gerschtli/dmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwm = {
      url = "github:Gerschtli/dwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwm-status = {
      url = "github:Gerschtli/dwm-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    teamspeak-update-notifier = {
      url = "github:Gerschtli/teamspeak-update-notifier";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , unstable
    , nixpkgs-for-jdk15
    , home-manager
    , nix-on-droid
    , agenix
    , agenix-cli
    , homeage
    , dmenu
    , dwm
    , dwm-status
    , teamspeak-update-notifier
    }: {
      overlay = final: prev: {
        inherit (nixpkgs-for-jdk15) jdk15;

        inherit (unstable.legacyPackages.${prev.system})
          # need bleeding edge version
          jetbrains
          portfolio
          teamspeak_server

          # TODO: remove as soon as available in stable
          jdk17_headless
          ventoy-bin
          ;

        gerschtli =
          prev.lib.foldr (a: b: a // b) { } (
            map (flake: flake.overlay final prev) [
              dmenu
              dwm
              dwm-status
              teamspeak-update-notifier
            ]);
      };
    };
}
