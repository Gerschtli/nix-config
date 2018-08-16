# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/45161 gets merged

self: super:


let
  inherit (super) fetchurl stdenv;

  version = "3.3.0";
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
        then "1jv5c1br3ypxz8px7fl5rg75j0kfdg8mqasdk2gka6yvgf7qc97i"
        else "0m889xl9iz3fmq7wyjjn42swprpspagbkn52a82nzkhgvagd45bz";
    };
  });
}
