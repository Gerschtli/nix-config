if [[ $# -ne 1 ]]; then
    >&2 echo "USAGE: $0 <devShell>"
    exit 1
fi

DEV_SHELL="${1}"

echo "use flake nix-config#${DEV_SHELL}" > .envrc
direnv allow .
