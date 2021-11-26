{
  description = "A collection of my system configs and dotfiles.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    nix-on-droid.url = "github:t184256/nix-on-droid";

    agenix.url = "github:ryantm/agenix";
    agenix-cli.url = "github:cole-h/agenix-cli";
    # homeage.url = "github:jordanisaacs/homeage";
    homeage.url = "github:Gerschtli/homeage/support-script";

    dmenu.url = "github:Gerschtli/dmenu";
    dwm.url = "github:Gerschtli/dwm";
    dwm-status.url = "github:Gerschtli/dwm-status";
    teamspeak-update-notifier.url = "github:Gerschtli/teamspeak-update-notifier";

    # commit before jdk15 drop
    # https://github.com/NixOS/nixpkgs/commit/9dde9d8b9ee4b7a4dfbb0ab1204d9f6f4a188360
    nixpkgs-for-jdk15.url = "github:NixOS/nixpkgs/df175b7f61d852dc599fe248b1a8666c312457bd";
  };

  outputs =
    { self
    , nixpkgs
    , unstable
    , home-manager
    , nix-on-droid
    , agenix
    , agenix-cli
    , homeage
    , dmenu
    , dwm
    , dwm-status
    , teamspeak-update-notifier
    , nixpkgs-for-jdk15
    }: { };
}
