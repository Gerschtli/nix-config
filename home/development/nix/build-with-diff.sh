@command@

echo

nix store diff-closures @activeLinkPath@ ./result

rm result
