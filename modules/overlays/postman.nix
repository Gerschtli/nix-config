# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/55585 got merged

self: super:

let
  # PR branch to update postman to 6.7.3
  pkgs = import ./util/pinned-pkgs.nix {
    inherit (super) fetchFromGitHub;

    rev = "58c97c5012a77702593ba7c822d8ecdba1520dae";
    sha256 = "1xj41j6jb9kizhiww5ksxaxf3h3lrvfd5xmdvbgx4nfznvp0dik0";
  };
in

{ inherit (pkgs) postman; }
