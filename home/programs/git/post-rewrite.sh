INCLUDES=(@includes@)

source @hooksLib@

if [[ "${1}" = "rebase" ]]; then
    run_scripts post-merge "$@"
fi
