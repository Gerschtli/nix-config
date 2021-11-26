INCLUDES=(@includes@)

source @hooksLib@

# has new commits and is branch checkout
if [[ "${1}" != "${2}" && "${3}" == 1 ]]; then
    run_scripts post-checkout "$@"
fi
