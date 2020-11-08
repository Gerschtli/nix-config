{ lib, pkgs }:

{
  wrapProgram = { name, source, path, packages }:
    if packages == []
    then source
    else pkgs.runCommand "${name}-wrapped" { } ''
      . ${pkgs.makeWrapper}/nix-support/setup-hook

      mkdir -p $out/bin
      ln -sn "${source}${path}" "$out${path}"

      wrapProgram "$out${path}" --prefix PATH : "${lib.makeBinPath packages}"
    '';
}
