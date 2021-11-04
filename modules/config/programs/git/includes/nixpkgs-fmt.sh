source @hooksLib@

shopt -s globstar

check() {
    nixpkgs-fmt --check ./**/*.nix; track_result
}

if [[ "${HOOK_TYPE}" = "pre-commit" ]]; then
    check
fi

exit "${RESULT}"
