self: super:

let
  version = "1.0.77.338.g758ebd78-41";
in

{
  spotify = super.spotify.overrideDerivation (old: {
    name = "spotify-${version}";

    src = super.fetchurl {
      url = "https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_${version}_amd64.deb";
      sha256 = "1971jc0431pl8yixpl37ryl2l0pqdf0xjvkg59nqdwj3vbdx5606";
    };
  });
}
