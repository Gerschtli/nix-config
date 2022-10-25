{ lib }:

{
  listNixFilesRecursive = path: builtins.filter
    (lib.hasSuffix ".nix")
    (lib.filesystem.listFilesRecursive path);
}
