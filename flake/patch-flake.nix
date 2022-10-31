{ nixpkgs, system, name, flake, patches, narHash }:

let
  pkgs = nixpkgs.legacyPackages.${system};

  root = pkgs.applyPatches {
    inherit patches;
    name = "${name}-patched";
    src = flake;
  };

  callFlake = import "${pkgs.nix.src}/src/libexpr/flake/call-flake.nix";

  lockFileStr = builtins.readFile "${root}/flake.lock";

  rootSrc = builtins.fetchTree {
    inherit narHash;
    type = "path";
    path = toString root;
  };
in

callFlake lockFileStr rootSrc ""
