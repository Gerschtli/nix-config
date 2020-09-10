#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

print_url() {
    local url="$(git remote get-url origin --push)"

    if [[ "${url}" =~ ^git@bitbucket.org:(.*)\.git$ ]]; then
        local repo_path="${BASH_REMATCH[1]}"
        local branch="$(git symbolic-ref --short --quiet HEAD)"

        if [[ "${branch}" =~ ^FEATURES-([0-9]+)- ]]; then
            local feature_branch="$(git branch --list "origin/FEATURES-${BASH_REMATCH[1]}-*" --remotes |
                grep --regexp ".*FEATURES-${BASH_REMATCH[1]}-[^0-9]\{4,\}-.*" |
                sed -e "s#^.*origin/##"
            )"

            echo
            echo "https://bitbucket.org/${repo_path}/pull-requests/new?source=${branch}&dest=${feature_branch}"
            echo
        fi
    fi
}

case "${HOOK_TYPE}" in
    pre-push) print_url ;;
esac

exit ${RESULT}
