@command@ build --flake "@homeDirectory@/.nix-config"

echo

@nixFlakes@/bin/nix store diff-closures @activeLinkPath@ ./result

rm result
