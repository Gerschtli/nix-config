{ lib, pkgs }:

{
  wrapProgram = { name, source, path, pathsToLink ? [ ], packages }:
    if packages == [ ]
    then source
    else
      pkgs.runCommand "${name}-wrapped" { } ''
        . ${pkgs.makeWrapper}/nix-support/setup-hook

        ${lib.concatMapStringsSep "\n" (p: ''
          mkdir -p "$(dirname "$out${p}")"
          ln -sn "${source}${p}" "$out${p}"
        '') (pathsToLink ++ [ path ])}

        # desktop entry
        mkdir -p "$out/share/applications"
        sed -e "s|Exec=.*$|Exec=$out/bin/${name}|" "${source}/share/applications/${name}.desktop" > "$out/share/applications/${name}.desktop"

        wrapProgram "$out/${path}" --prefix PATH : "${lib.makeBinPath packages}"
      '';
}
