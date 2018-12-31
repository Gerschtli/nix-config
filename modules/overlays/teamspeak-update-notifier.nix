self: super:

let
  inherit (self) python36 python36Packages;
  inherit (super) fetchFromGitHub;
in

{
  teamspeak-update-notifier = python36.pkgs.buildPythonPackage rec {
    pname = "teamspeak-update-notifier";
    version = "1.4.1";

    src = fetchFromGitHub {
      owner = "Gerschtli";
      repo = "teamspeak-update-notifier";
      rev = version;
      sha256 = "1pzlzbinwb9fbif99ckaca9awd7mz6i827bw5i2hprrzwmhqzr1q";
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
