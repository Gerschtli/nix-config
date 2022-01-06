{ lib, pkgs }:

{
  wrapProgram = { name, source, path, pathsToLink ? [ ], packages }:
    if packages == [ ]
    then source
    else
      pkgs.runCommand "${name}-wrapped" { } ''
        . ${pkgs.makeWrapper}/nix-support/setup-hook

        ${lib.concatMapStringsSep "\n" (p: ''
          mkdir -p "$(dirname "${(placeholder "out") + p}")"
          ln -sn "${source + p}" "${(placeholder "out") + p}"
        '') (pathsToLink ++ [ path ])}

        # desktop entry
        mkdir -p "${placeholder "out"}/share/applications"
        sed -e "s|Exec=.*$|Exec=${placeholder "out"}/bin/${name}|" \
          "${source}/share/applications/${name}.desktop" \
          > "${placeholder "out"}/share/applications/${name}.desktop"

        wrapProgram "${placeholder "out"}/${path}" --prefix PATH : "${lib.makeBinPath packages}"
      '';
}
