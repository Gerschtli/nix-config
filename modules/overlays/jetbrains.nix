self: super:

let
  # Update intellij packages
  pkgs = import ./util/pinned-pkgs.nix {
    inherit (super) fetchFromGitHub;

    owner = "Gerschtli";
    rev = "47d74045e9a797575ca2fabc9ebe38321b3fb433";
    sha256 = "1cz58pmy9mcs377h03kbb201smsqi3gnxc29p8g8fvjq6c3wxlbq";
  };
in

{
  inherit (pkgs) jetbrains;
}
