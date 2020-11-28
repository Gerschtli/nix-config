self: super:

let
  inherit (super) fetchurl stdenv;

  version = "3.13.2";
  arch = if stdenv.is64bit then "amd64" else "x86";
  libDir = if stdenv.is64bit then "lib64" else "lib";
in

{
  teamspeak_server = super.teamspeak_server.overrideDerivation (old: rec {
    name = "teamspeak-server-${version}";

    src = fetchurl {
      url = "https://files.teamspeak-services.com/releases/server/${version}/teamspeak3-server_linux_${arch}-${version}.tar.bz2";
      sha256 = if stdenv.is64bit
        then "1l9i9667wppwxbbnf6kxamnqlbxzkz9ync4rsypfla124b6cidpz"
        else "0qhd05abiycsgc16r1p6y8bfdrl6zji21xaqwdizpr0jb01z335g";
    };

    buildInputs = old.buildInputs ++ [ super.postgresql.lib ];
  });
}
