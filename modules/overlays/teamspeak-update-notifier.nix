self: super:

let
  inherit (self) python36 python36Packages;
  inherit (super) fetchFromGitHub;

  dependency_injector = python36Packages.buildPythonPackage rec {
    pname = "dependency_injector";
    version = "3.13.1";

    src = fetchFromGitHub {
      owner = "ets-labs";
      repo = pname;
      rev = version;
      sha256 = "03cn4aanz6q28vy5946bpbmnpg25szzp0q3m4wk82ardw5j6x07i";
    };

    doCheck = false;

    propagatedBuildInputs = with python36Packages; [ six ];
  };
in

{
  teamspeak-update-notifier = python36.pkgs.buildPythonPackage rec {
    pname = "teamspeak-update-notifier";
    version = "1.3.1";

    src = fetchFromGitHub {
      owner = "Gerschtli";
      repo = "teamspeak-update-notifier";
      rev = version;
      sha256 = "1hrvw8q928cnqxbhz1dl550g6zy33agwxgbf4vk6yj04j72x141v";
    };

    doCheck = false;

    propagatedBuildInputs = with python36Packages; [
      beautifulsoup4
      dependency_injector
      requests
    ];
  };
}
