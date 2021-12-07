{ lib, pkgs }:

with lib;

let
  builder =
    { destPath
    , envs
    , executable ? false
    , file
    , name
    , path ? [ ]
    , preamble
    }:
    pkgs.runCommand
      name
      (envs // {
        inherit (pkgs) runtimeShell;
        bashLib = ./lib.sh;
        path =
          makeBinPath (path ++ [ pkgs.coreutils ])
            + optionalString (envs ? _doNotClearPath && envs._doNotClearPath) ":\${PATH}";
      })
      ''
        file=${destPath}
        mkdir --parents "$(dirname "$file")"

        cat ${preamble} "${file}" > "$file"
        substituteAllInPlace "$file"

        ${pkgs.shellcheck}/bin/shellcheck \
          --check-sourced \
          --enable all \
          --external-sources \
          --shell bash \
          "$file"

        ${optionalString executable ''
          chmod +x "$file"
        ''}
      '';
in

{
  mkScript = name: file: path: envs:
    builder {
      inherit name file path envs;
      destPath = "$out/bin/${name}";
      executable = true;
      preamble = ./preamble.sh;
    };

  mkScriptPlain = name: file: path: envs:
    builder {
      inherit name file path envs;
      destPath = "$out";
      executable = true;
      preamble = ./preamble.sh;
    };

  mkZshCompletion = name: file: envs:
    builder {
      inherit file;
      name = "${name}-completion";
      destPath = "$out/share/zsh/site-functions/_${name}";
      preamble = ./preamble.completion.zsh;
      envs = envs // {
        inherit name;
        completionLib = ./lib.completion.zsh;
      };
    };
}
