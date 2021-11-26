source @hooksLib@

check() {
    find . -type f -iname "*.nix" -exec nixpkgs-fmt --check {} \+; track_result
}

if [[ "${HOOK_TYPE}" = "pre-commit" ]]; then
    check
fi

exit "${RESULT}"
