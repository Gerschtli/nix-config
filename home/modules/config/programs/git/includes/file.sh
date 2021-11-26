source @hooksLib@

check() {
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
        against=HEAD
    else
        against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
    fi

    # test for trailing whitespaces
    git diff-index --check --cached "${against}" --; track_result
}

if [[ "${HOOK_TYPE}" = "pre-commit" ]]; then
    check
fi

exit "${RESULT}"
