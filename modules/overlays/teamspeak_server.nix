self: super:

let
  inherit (super) fetchurl stdenv;

  version = "3.10.2";
  arch = if stdenv.is64bit then "amd64" else "x86";
  libDir = if stdenv.is64bit then "lib64" else "lib";
in

{
  teamspeak_server = super.teamspeak_server.overrideDerivation (old: rec {
    name = "teamspeak-server-${version}";

    src = fetchurl {
      url = "https://files.teamspeak-services.com/releases/server/${version}/teamspeak3-server_linux_${arch}-${version}.tar.bz2";
      sha256 = if stdenv.is64bit
        then "03c717qjlbym02nwy82l6jhrkbidsdm1jv5k8p3c10p6a46jy9nl"
        else "1ay0lmbv2rw9klz289yg0hhsac83kfzzlbwwhjpi28xndl2lq4bf";
    };
  });
}
