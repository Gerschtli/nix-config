{ system, pkgsFor, customLibFor, name, args, ... }:

let
  script = customLibFor.${system}.mkScript
    name
    args.file
    (args.path pkgsFor.${system})
    (args.envs or { });
in

{
  type = "app";
  program = "${script}/bin/${name}";
}
