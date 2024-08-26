source @hooksLib@

check() {
    if ! grep "gitleaks protect" lefthook.yaml &> /dev/null; then
        return
    fi

    gitleaks protect --verbose --redact --staged; track_result
}

if [[ "${HOOK_TYPE}" = "pre-commit" ]]; then
    check
fi

exit "${RESULT}"
