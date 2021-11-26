source @hooksLib@

if [[ "${HOOK_TYPE}" = @(post-checkout|post-commit|post-merge|pre-push) ]]; then
    git lfs "$@"
fi

exit "${RESULT}"
