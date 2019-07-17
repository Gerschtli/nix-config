#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

PACKAGE_JSON="${PWD}/package.json"

install() {
    if has_changed "${PACKAGE_JSON}"; then
        npm ci
    fi
}

check() {
    if npm run | has_match "  test$"; then
        npm run-script test; track_result
    elif npm run | has_match "  verify$"; then
        npm run-script verify; track_result
    fi
}

if has_command_and_file npm "${PACKAGE_JSON}"; then
    case "${HOOK_TYPE}" in
        post-checkout | post-merge) install ;;
        pre-push)                   check   ;;
    esac
fi

exit ${RESULT}
