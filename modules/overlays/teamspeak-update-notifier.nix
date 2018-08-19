self: super:

let
  inherit (self) python36 python36Packages;
  inherit (super) fetchFromGitHub;
in

{
  teamspeak-update-notifier = python36.pkgs.buildPythonPackage rec {
    pname = "teamspeak-update-notifier";
    version = "1.1.0";

    src = fetchFromGitHub {
      owner = "Gerschtli";
      repo = "teamspeak-update-notifier";
      rev = version;
      sha256 = "0gjv0w56irsz1m6hq7nv97k5lzmiis67r5z0qc78y4dvibmf6554";
    };

    doCheck = false;

    propagatedBuildInputs = with python36Packages; [
      beautifulsoup4
      requests
    ];
  };
}
