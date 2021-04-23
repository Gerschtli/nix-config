{ lib }:

let
  inherit (builtins) readDir;
  inherit (lib) flatten hasSuffix mapAttrsToList optional;

  getFileList = recursive: isValidFile: path:
    let
      contents = readDir path;

      list = mapAttrsToList
        (name: type:
          let
            newPath = path + ("/" + name);
          in
            if type == "directory"
            then
              if recursive
              then getFileList true isValidFile newPath
              else [ ]
            else optional (isValidFile newPath) newPath
        )
        contents;
    in
      flatten list;
in

{
  getFileList = getFileList false (x: true);
  getRecursiveNixFileList = getFileList true (hasSuffix ".nix");
}
