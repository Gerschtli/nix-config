_:

{ lib, pkgs, homeModules ? [ ], inputs, rootPath, ... }:

{
  homeManager = {
    baseConfig = {
      backupFileExtension = "hm-bak";
      extraSpecialArgs = { inherit inputs rootPath; };
      sharedModules = homeModules;
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    userConfig = host: user: "${rootPath}/hosts/${host}/home-${user}.nix";
  };

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://gerschtli.cachix.org"
        "https://nix-on-droid.cachix.org"
      ];
      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      ];
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 30;
      flake-registry = null;
    };

    package = pkgs.nixVersions.latest;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      nix-config.flake = inputs.self;
    };
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };
}
