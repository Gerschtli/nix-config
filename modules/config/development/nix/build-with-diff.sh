@command@ build

echo

# see https://github.com/madjar/nox/issues/63#issuecomment-303280129
nox-update --quiet @activeLinkPath@ result |
    grep -v '\.drv : $' |
    sed 's|^ */nix/store/[a-z0-9]*-||' |
    sort -u || :

rm result
