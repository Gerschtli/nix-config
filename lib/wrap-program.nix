{ lib, pkgs }:

{
  wrapProgram = { name, desktopFileName ? name, source, path, packages ? [ ], flags ? [ ], fixGL ? false }:
    if packages == [ ] && flags == [ ] && !fixGL
    then source
    else
      pkgs.symlinkJoin {
        name = "${name}-wrapped";
        paths = [ source ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild =
          let
            inherit (lib)
              concatMapStringsSep
              escapeShellArg
              filter
              hasPrefix
              splitString
              readFile
              ;

            desktopEntryPath = "/share/applications/${desktopFileName}.desktop";
            out = placeholder "out";

            content = readFile "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel";
            lines = splitString "\n" content;

            filteredLines = filter (line: !(hasPrefix "#!/" line) && !(hasPrefix "exec " line)) lines;
            wrapProgramArgsForFixGL = concatMapStringsSep " " (line: "--run ${escapeShellArg line}") filteredLines;
          in
          ''
            # desktop entry
            if [[ -L "${out}/share/applications" ]]; then
              rm "${out}/share/applications"
              mkdir "${out}/share/applications"
            else
              rm "${out + desktopEntryPath}"
            fi

            sed -e "s|Exec=${source + path}|Exec=${out + path}|" \
              "${source + desktopEntryPath}" \
              > "${out + desktopEntryPath}"

            wrapProgram "${out + path}" \
              ${lib.optionalString fixGL wrapProgramArgsForFixGL} \
              ${lib.optionalString (packages != []) ''--prefix PATH : "${lib.makeBinPath packages}"''} \
              ${lib.optionalString (flags != []) ''--add-flags "${toString flags}"''}
          '';
      };
}
