source @hooksLib@

check() {
    nix flake check --log-format bar-with-logs; track_result
}

if [[ "${HOOK_TYPE}" = "pre-push" && -f "flake.nix" ]]; then
    check
fi

exit "${RESULT}"
