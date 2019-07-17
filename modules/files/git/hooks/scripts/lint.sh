#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

LINTER="${PWD}/ci/lint.sh"

check() {
    "${LINTER}"; track_result
}

if [[ -x "${LINTER}" ]]; then
    case "${HOOK_TYPE}" in
        pre-push) check ;;
    esac
fi

exit ${RESULT}
