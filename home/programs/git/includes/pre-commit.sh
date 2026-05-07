source @hooksLib@

check() {
    if [[ ! -f .pre-commit-config.yaml ]]; then
        return
    fi

    INSTALL_PYTHON=.venv/bin/python
    ARGS=(hook-impl --config=.pre-commit-config.yaml --hook-type="${HOOK_TYPE}" --hook-dir . -- "${HOOK_ARGS[@]}")

    if [[ -x "${INSTALL_PYTHON}" ]]; then
        "${INSTALL_PYTHON}" -mpre_commit "${ARGS[@]}"; track_result
    elif command -v pre-commit > /dev/null; then
        pre-commit "${ARGS[@]}"; track_result
    else
        echo 'pre-commit config found but pre-commit not found.' 1>&2
        false; track_result
    fi
}

if [[ "${HOOK_TYPE}" =~ ^(pre-commit|commit-msg)$ ]]; then
    check
fi

exit "${RESULT}"
