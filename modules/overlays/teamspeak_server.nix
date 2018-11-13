# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/50327 gets merged

self: super:


let
  inherit (super) fetchurl stdenv;

  version = "3.5.0";
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
        then "0zk7rbi6mvs2nnsjhv4aizl5ydiyr46ng2i3lr8r78gyb88nxmcv"
        else "0nahsmcnykgchgv50jb22fin74sab1zl8gy6m6s8mjk570qlvzzm";
    };
  });
}
