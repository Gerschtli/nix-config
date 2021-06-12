#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

check() {
    local git="git"

    # workaround for messed up PATH, don't use atom's git
    if ! $(git --version > /dev/null 2>&1); then
        git=$(which -a git | head -n 2 | tail -n 1)
    fi

    if $git rev-parse --verify HEAD >/dev/null 2>&1; then
        against=HEAD
    else
        against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
    fi

    # test for trailing whitespaces
    $git diff-index --check --cached $against --; track_result
}

case "${HOOK_TYPE}" in
    pre-commit) check ;;
esac

exit ${RESULT}
