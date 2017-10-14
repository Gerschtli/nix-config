{ lib }:

let
  inherit (builtins) readDir;
  inherit (lib) flatten mapAttrsToList;

  getRecursiveFileList = path:
    let
      contents = readDir path;

      list = mapAttrsToList
        (name: type:
          let
            newPath = path + ("/" + name);
          in
            if type == "directory"
            then getRecursiveFileList newPath
            else [ newPath ]
        )
        contents;
    in

    flatten list;
in

getRecursiveFileList
