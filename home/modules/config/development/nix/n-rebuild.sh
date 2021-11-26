mode="${1}"
forks=("${@:2}")

_usage() {
    echo "$0 <debug|dev|build|test|switch> [fork]*"
}

args=(--keep-going)
case "${mode}" in
    debug) args+=(test --fast --show-trace) ;;
    dev) args+=(test --fast) ;;
    build)
        "@buildCmd@"
        exit
        ;;
    test) args+=(test) ;;
    switch) args+=(switch) ;;
    *)
        _usage
        exit 1
        ;;
esac

for fork in "${forks[@]}"; do
    args+=(-I "${fork}=@forkDir@/${fork}")
done

before_date=$(date +"%Y-%m-%d %H:%M:%S")

nixos-rebuild "${args[@]}"; result=$?

for user in root tobias; do
    echo
    journalctl --identifier "hm-activate-${user}" --since "${before_date}" --output cat |
        ccze --raw-ansi
done

exit "${result}"
