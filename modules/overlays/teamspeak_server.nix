self: super:

let
  inherit (super) fetchurl stdenv;

  version = "3.6.1";
  arch = if stdenv.is64bit then "amd64" else "x86";
in

{
  teamspeak_server = super.teamspeak_server.overrideDerivation (old: rec {
    name = "teamspeak-server-${version}";

    src = fetchurl {
      urls = [
        "http://dl.4players.de/ts/releases/${version}/teamspeak3-server_linux_${arch}-${version}.tar.bz2"
        "http://teamspeak.gameserver.gamed.de/ts3/releases/${version}/teamspeak3-server_linux_${arch}-${version}.tar.bz2"
      ];
      sha256 = if stdenv.is64bit
        then "0wgnb7fdy393anridymm1frlgr86j0awxnzvd498ar5fch06ij87"
        else "0x6p1z4qvgy464n6gnkaqrm7dns1ysyadm68sr260d39a7028q1c";
    };
  });
}
