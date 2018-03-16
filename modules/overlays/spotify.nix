self: super:

let
  version = "1.0.72.117.g6bd7cc73-35";
in

{
  spotify = super.spotify.overrideDerivation (old: {
    name = "spotify-${version}";

    src = super.fetchurl {
      url = "https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_${version}_amd64.deb";
      sha256 = "0yicwvg6jx8r657ff53326akq3g4ayiinlracjw5jrcs8x9whjap";
    };
  });
}
