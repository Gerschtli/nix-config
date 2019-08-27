with import <nixpkgs> { };

mkShell {
  name = "ansible";

  buildInputs = [
    ansible
  ];
}
