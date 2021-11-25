@command@ build

echo

@nixUnstable@/bin/nix store diff-closures @activeLinkPath@ ./result

rm result
