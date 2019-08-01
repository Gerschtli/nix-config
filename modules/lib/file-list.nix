{ lib }:

let
  inherit (builtins) readDir;
  inherit (lib) flatten mapAttrsToList optional optionals;

  getDirectoryList = recursive: path:
    let
      contents = readDir path;

      list = mapAttrsToList
        (name: type:
          let
            newPath = path + ("/" + name);
          in
            optionals (type == "directory") (
              optionals recursive (getDirectoryList true newPath)
              ++ [ newPath ]
            )
        )
        contents;
    in
      flatten list;

  getFileList = recursive: path:
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
              then getFileList true newPath
              else [ ]
            else [ newPath ]
        )
        contents;
    in
      flatten list;
in

{
  getDirectoryList = getDirectoryList false;
  getRecursiveDirectoryList = getDirectoryList true;

  getFileList = getFileList false;
  getRecursiveFileList = getFileList true;
}
