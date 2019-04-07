self: super:

let
  inherit (super) fetchurl stdenv;

  version = "3.7.1";
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
        then "1w60241zsvr8d1qlkca6a1sfxa1jz4w1z9kjd0wd2wkgzp4x91v7"
        else "0s835dnaw662sb2v5ahqiwry0qjcpl7ff9krnhbw2iblsbqis3fj";
    };
  });
}
