_:

{ homeModules ? [ ], inputs, rootPath, ... }:

{
  homeManager = {
    baseConfig = {
      backupFileExtension = "hm-bak";
      extraSpecialArgs = { inherit inputs rootPath; };
      sharedModules = homeModules;
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    userConfig = host: user: "${rootPath}/hosts/${host}/home-${user}.nix";
  };
}
