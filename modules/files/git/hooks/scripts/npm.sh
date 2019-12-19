#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

PACKAGE_JSON="${PWD}/package.json"

install() {
    if has_changed "${PACKAGE_JSON}" && ! is_submodule; then
        npm ci
    fi
}

if has_command_and_file npm "${PACKAGE_JSON}"; then
    case "${HOOK_TYPE}" in
        post-checkout | post-merge) install ;;
    esac
fi

exit ${RESULT}
