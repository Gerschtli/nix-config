self: super:

let
  inherit (super) fetchurl stdenv;

  version = "3.8.0";
  arch = if stdenv.is64bit then "amd64" else "x86";
  libDir = if stdenv.is64bit then "lib64" else "lib";
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
        then "1bzmqqqpwn6q2pvkrkkxq0ggs8crxbkwaxlggcdxjlyg95cyq8k1"
        else "0p5rqwdsvbria5dzjjm5mj8vfy0zpfs669wpbwxd4g3n4vh03kyw";
    };

    installPhase = ''
      # Delete unecessary libraries - these are provided by nixos.
      #rm *.so*

      # Install files.
      mkdir -p $out/lib/teamspeak
      mv * $out/lib/teamspeak/

      # Make symlinks to the binaries from bin.
      mkdir -p $out/bin/
      ln -s $out/lib/teamspeak/ts3server $out/bin/ts3server
      ln -s $out/lib/teamspeak/tsdnsserver $out/bin/tsdnsserver

      wrapProgram $out/lib/teamspeak/ts3server \
        --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/${libDir} \
        --prefix LD_LIBRARY_PATH : $out/lib/teamspeak
    '';
  });
}
