{ lib, pkgs }:

{
  wrapProgram = { name, desktopFileName ? name, source, path, pathsToLink ? [ ], packages ? [ ], flags ? [ ], fixGL ? false }:
    if packages == [ ] && flags == [ ] && !fixGL
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
          ${
            let
              inherit (builtins) filter readFile;
              inherit (lib) concatMapStringsSep escapeShellArg hasPrefix splitString;

              content = readFile "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel";
              lines = splitString "\n" content;

              filteredLines = filter (line: !(hasPrefix "#!/" line) && !(hasPrefix "exec " line)) lines;
              arguments = concatMapStringsSep " " (line: "--run ${escapeShellArg line}") filteredLines;
            in
            lib.optionalString fixGL arguments
          } \
          ${lib.optionalString (packages != []) ''--prefix PATH : "${lib.makeBinPath packages}"''} \
          ${lib.optionalString (flags != []) ''--add-flags "${toString flags}"''}
      '';
}
