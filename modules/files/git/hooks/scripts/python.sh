#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

SETUP_PY="${PWD}/setup.py"

check() {
    python "${SETUP_PY}" test; track_result
}

if has_command_and_file python "${SETUP_PY}"; then
    case "${HOOK_TYPE}" in
        pre-push) check ;;
    esac
fi

exit ${RESULT}
