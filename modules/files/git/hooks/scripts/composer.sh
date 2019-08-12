#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

COMPOSER_LOCK="${PWD}/composer.lock"

install() {
    if has_changed "${COMPOSER_LOCK}" && ! is_submodule; then
        composer install --optimize-autoloader --prefer-source
    fi
}

check() {
    if composer list --raw | has_match "^verify\s+"; then
        composer verify; track_result
    fi
}

if has_command_and_file php "${COMPOSER_LOCK}"; then
    case "${HOOK_TYPE}" in
        post-checkout | post-merge) install ;;
        pre-push)                   check   ;;
    esac
fi

exit ${RESULT}
