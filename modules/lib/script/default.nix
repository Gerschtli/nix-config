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

  buildZshCompletion = name: file: substitutes:
    pkgs.runCommand
      "${name}-completion"
      (substitutes // {
        inherit name;
      })
      ''
        file=$out/share/zsh/site-functions/_${name}
        mkdir --parents $out/share/zsh/site-functions

        cat "${./preamble.completion.zsh}" "${file}" > "$file"
        substituteAllInPlace "$file"

        ${pkgs.shellcheck}/bin/shellcheck \
          --check-sourced \
          --enable all \
          --external-sources \
          --shell bash \
          "$file"
      '';
}
