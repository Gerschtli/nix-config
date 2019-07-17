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

    if [[ -z "${GIT_HOOKS_MAX_LINE_LENGTH}" ]]; then
        return
    fi

    # test for lines longer than x chars in added lines
    [[ $($git diff --cached | grep "^\+" | sed -e 's,^\+,,' | wc -L) -le "${GIT_HOOKS_MAX_LINE_LENGTH}" ]]
    local last_result=$?
    track_result ${last_result}

    if [[ ${last_result} != 0 ]]; then
        echo "Max line length of ${GIT_HOOKS_MAX_LINE_LENGTH} is exeeded!"
        echo
        printf '=%.0s' $(seq 2 ${GIT_HOOKS_MAX_LINE_LENGTH}) && echo "|"
        $git diff --cached | grep -C 2 "^\+.\{$((${GIT_HOOKS_MAX_LINE_LENGTH} + 1)),\}" | sed -e 's,^[+-],,'
        printf '=%.0s' $(seq 2 ${GIT_HOOKS_MAX_LINE_LENGTH}) && echo "|"
    fi
}

case "${HOOK_TYPE}" in
    pre-commit) check ;;
esac

exit ${RESULT}
