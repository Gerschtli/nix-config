@command@ build --flake "@homeDirectory@/.nix-config"

echo

nix store diff-closures @activeLinkPath@ ./result

rm result
