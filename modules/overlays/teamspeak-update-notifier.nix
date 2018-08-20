self: super:

let
  inherit (self) python36 python36Packages;
  inherit (super) fetchFromGitHub;
in

{
  teamspeak-update-notifier = python36.pkgs.buildPythonPackage rec {
    pname = "teamspeak-update-notifier";
    version = "1.2.0";

    src = fetchFromGitHub {
      owner = "Gerschtli";
      repo = "teamspeak-update-notifier";
      rev = version;
      sha256 = "0wdq666zs7llc4qg9730i93yszlq20qzglhcynd1r7jg449z7ghz";
    };

    doCheck = false;

    propagatedBuildInputs = with python36Packages; [
      beautifulsoup4
      requests
    ];
  };
}
