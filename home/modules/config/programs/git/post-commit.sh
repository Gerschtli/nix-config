INCLUDES=(@includes@)

source @hooksLib@

run_scripts post-commit "$@"
