{ lib, pkgs }:

{
  wrapProgram = { name, source, path, packages }:
    if packages == [ ]
    then source
    else
      pkgs.runCommand "${name}-wrapped" { } ''
        . ${pkgs.makeWrapper}/nix-support/setup-hook

        file="$out${path}"
        mkdir -p "$(dirname "$file")"
        ln -sn "${source}${path}" "$file"

        # link share for desktop entries
        ln -sn "${source}/share" "$out/share"

        wrapProgram "$file" --prefix PATH : "${lib.makeBinPath packages}"
      '';
}
