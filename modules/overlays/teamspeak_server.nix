# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/45161 gets merged

self: super:


let
  inherit (super) fetchurl stdenv;

  version = "3.4.0";
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
        then "12wis5sbbx502g86irhi3g2gvpczbxzjw7z0lw9rk7jagplwhvkx"
        else "01ajiqizy4f8niqipxccimvvsqlfypr4a28rwxk6zran7m1kjpp6";
    };
  });
}
