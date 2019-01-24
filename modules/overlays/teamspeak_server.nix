# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/54547 gets merged

self: super:

let
  inherit (super) fetchurl stdenv;

  version = "3.5.1";
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
        then "0ygb867ff2fvi9n9hgs4hldpg4y012w4i1d9cx4f5mpli1xim6da"
        else "0g1cixsldpdbfzg2vain7h3hr5j3xjdngjw66r0aqnzbx743gjzj";
    };
  });
}
