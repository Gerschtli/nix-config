{ lib, pkgs }:

let
  inherit (lib)
    makeBinPath
    optionalString;

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
          --exclude SC2310,SC2312 \
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
      destPath = "${placeholder "out"}/bin/${name}";
      executable = true;
      preamble = ./preamble.sh;
    };

  mkScriptPlain = name: file: path: envs:
    builder {
      inherit name file path envs;
      destPath = placeholder "out";
      executable = true;
      preamble = ./preamble.sh;
    };

  mkZshCompletion = name: file: envs:
    builder {
      inherit file;
      name = "${name}-completion";
      destPath = "${placeholder "out"}/share/zsh/site-functions/_${name}";
      preamble = ./preamble.completion.zsh;
      envs = envs // {
        inherit name;
        completionLib = ./lib.completion.zsh;
      };
    };
}
