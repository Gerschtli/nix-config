{ inputsOriginal, rootPath, forEachSystem }:

let
  #inputsFor = forEachSystem (system: inputsOriginal);
  patchFlakeFor = forEachSystem (system: import ./patch-flake.nix {
    inherit (inputsOriginal) nixpkgs;
    inherit system;
  });

  inputsFor = forEachSystem (system:
    inputsOriginal // {
      nixpkgs = patchFlakeFor.${system} {
        name = "nixpkgs";
        flake = inputsOriginal.nixpkgs;
        patches = [ ./nixpkgs-systemd-boot-builder-master-2e92b7cf573989edf8e2f153bdc91bfc5b906064.patch ];
        /*map
          ({ rev, sha256 }: inputsOriginal.nixpkgs.legacyPackages.${system}.fetchpatch {
          url = "https://github.com/NixOS/nixpkgs/commit/${rev}.patch";
          inherit sha256;
          })
          [
          { rev = "a30de3b849bb29b4d2206e1a652707fba8ea18a4"; sha256 = "sha256-+DRB7mcrPgCGTn3D5hH1gPqSyPZYZMyiNyc8PHQE1po="; }
          { rev = "ff24f484afbbde86aef3f8850034e3e42977db32"; sha256 = "sha256-8/GjEB+fNTHGdo+NwnvVuqwUAYiUZh1cIOOLpMv2M38="; }
          { rev = "4396fd615c4c5061c690b03e0b278ff73bc509e2"; sha256 = "sha256-TEr+4PBsFOeMg6ky4+EpUkucre0pk/D6BQyk+ZsZXl0="; }
          { rev = "771ef9f73897ee57ec28a8f0861b556959db4d48"; sha256 = "sha256-9ybHGVJK898wLAlY2MQNBuQZKRZEsk4kKGre/M74zIY="; }
          { rev = "642323930effc0c520c66ff31d84e00d481f2813"; sha256 = "sha256-A8wxAgUWUFUPsRXPA8aPMPz+q69YBJZb3Omd4PcSvHo="; }
          { rev = "437f73dd546e1cbaaa9de576608bdfa0281659e3"; sha256 = "sha256-+kTo8S7mHrQBVmq0S/Fzsi3RYNHF7Icdr51FFCIDEJ8="; }
          { rev = "42c94928296294aeed01e7ac9c77a664a4abddf3"; sha256 = "sha256-OMrgD9VTLpKJEDmKSVoYwsBSwAg6kQHrLoK/amt8ydc="; }
          ];*/
        narHash = "0a7ac2c4fb9dcdd19f3783333045dd3d24291b3dbd17c1de0dd1e19a7b688e13";
      };
    }
  );

  pkgsFor = forEachSystem (system: import ./nixpkgs.nix {
    inherit system;
    inputs = inputsFor.${system};
  });
  pkgsNixOnDroidFor = forEachSystem (system: import ./nixpkgs.nix {
    inherit system;
    inputs = inputsFor.${system};
    nixOnDroid = true;
  });

  customLibFor = forEachSystem (system: import "${rootPath}/lib" {
    pkgs = pkgsFor.${system};
  });

  homeModulesFor = forEachSystem (system:
    [
      {
        _file = ./default.nix;
        lib.custom = customLibFor.${system};
      }
      inputsFor.${system}.homeage.homeManagerModules.homeage
    ]
    ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/home"
  );

  wrapper = builder: system: name: args:
    inputsFor.${system}.nixpkgs.lib.nameValuePair
      name
      (import builder {
        inherit rootPath system pkgsFor pkgsNixOnDroidFor customLibFor homeModulesFor name args;
        inputs = inputsFor.${system};
      });

  simpleWrapper = builder: system: name: wrapper builder system name { };
in

{
  mkHome = simpleWrapper ./builders/mkHome.nix;
  mkNixOnDroid = simpleWrapper ./builders/mkNixOnDroid.nix;
  mkNixos = simpleWrapper ./builders/mkNixos.nix;

  mkApp = wrapper ./builders/mkApp.nix;
  mkDevShellJdk = wrapper ./builders/mkDevShellJdk.nix;
  mkDevShellPhp = wrapper ./builders/mkDevShellPhp.nix;
}
