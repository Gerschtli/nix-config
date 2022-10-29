if [[ $# -ne 1 ]]; then
    echo >&2 "USAGE: nix run .#ci-build -- packages.x86_64-linux.name"
    exit 1
fi

ATTR_PATH="$1"

nix-build-uncached --no-out-link --expr "(builtins.getFlake \"@rootPath@\").${ATTR_PATH}"
