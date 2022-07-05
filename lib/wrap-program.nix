{ lib, pkgs }:

{
  wrapProgram = { name, desktopFileName ? name, source, path, pathsToLink ? [ ], packages ? [ ], flags ? [ ] }:
    if packages == [ ] && flags == [ ]
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
        sed -e "s|Exec=${source + path}|Exec=${placeholder "out"}/bin/${name}|" \
          "${source}/share/applications/${desktopFileName}.desktop" \
          > "${placeholder "out"}/share/applications/${desktopFileName}.desktop"

        wrapProgram "${placeholder "out"}/${path}" \
          ${lib.optionalString (packages != []) ''--prefix PATH : "${lib.makeBinPath packages}"''} \
          ${lib.optionalString (flags != []) ''--add-flags "${toString flags}"''}
      '';
}
