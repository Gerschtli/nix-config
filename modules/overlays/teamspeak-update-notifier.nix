self: super:

let
  inherit (self) python36 python36Packages;
  inherit (super) fetchFromGitHub;
in

{
  teamspeak-update-notifier = python36.pkgs.buildPythonPackage rec {
    pname = "teamspeak-update-notifier";
    version = "1.4.2";

    src = fetchFromGitHub {
      owner = "Gerschtli";
      repo = "teamspeak-update-notifier";
      rev = version;
      sha256 = "08s6xwjdppin8h27qjwkn9kkxgbls24w83zgakkv88pcp604cpsc";
    };

    propagatedBuildInputs = with python36Packages; [
      beautifulsoup4
      requests
    ];

    checkInputs = with python36Packages; [
      pytest
      pytestrunner
    ];
  };
}
