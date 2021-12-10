{ inputs, pkgs, customLib, name, args, ... }:

inputs.flake-utils.lib.mkApp {
  drv = customLib.mkScript
    name
    args.file
    (args.path pkgs)
    (args.envs or { });
}
