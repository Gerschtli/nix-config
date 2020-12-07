with import <nixpkgs> { };

mkShell {
  name = "ansible";

  buildInputs = [
    ansible_2_9
  ];
}
