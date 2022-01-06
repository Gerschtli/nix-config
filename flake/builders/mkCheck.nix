{ pkgs, name, args, ... }:

pkgs.runCommand name { } ''
  ${args.script pkgs}
  touch ${placeholder "out"}
''
