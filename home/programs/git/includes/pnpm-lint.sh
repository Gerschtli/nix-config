source @hooksLib@

check() {
    if ! hash pnpm &> /dev/null; then
        return
    fi

    if ! pnpm run | grep "^  lint$" &> /dev/null; then
        return
    fi

    pnpm run lint; track_result
}

if [[ "${HOOK_TYPE}" = "pre-commit" ]]; then
    check
fi

exit "${RESULT}"
