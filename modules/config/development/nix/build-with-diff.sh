@command@ build

echo

@nixUnstable@/bin/nix store diff-closures @activeLinkPath@ ./result --extra-experimental-features nix-command

rm result
