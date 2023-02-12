if [[ $# -lt 1 ]]; then
    >&2 echo "USAGE: $0 <NUMBER> [<DESCRIPTION>]?"
    exit 2
fi

ARGS="${*}"

git bc "feature/TRAP-${ARGS// /-}"
