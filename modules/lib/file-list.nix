{ lib }:

let
  inherit (builtins) readDir;
  inherit (lib) flatten mapAttrsToList;

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
  getFileList = getFileList false;
  getRecursiveFileList = getFileList true;
}
