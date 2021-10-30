{ lib, pkgs, ... }:

with lib;

{
  buildScript = name: file: path: envs:
    pkgs.runCommand
      name
      (envs // {
        inherit (pkgs) runtimeShell;
        bashLib = ./lib.sh;
        bashLibContent = builtins.readFile ./lib.sh;
        path =
          makeBinPath (path ++ [ pkgs.coreutils ])
          + optionalString (envs ? _doNotClearPath && envs._doNotClearPath) ":\${PATH}";
      })
      ''
        file=$out/bin/${name}
        mkdir --parents $out/bin

        cat "${./preamble.sh}" "${file}" > "$file"
        substituteAllInPlace "$file"

        ${pkgs.shellcheck}/bin/shellcheck \
          --check-sourced \
          --enable all \
          --external-sources \
          --shell bash \
          "$file"

        chmod +x "$file"
      '';
}
