HOOK_TYPE="${1:-}"
RESULT=0

# credits to
#  - https://github.com/greg0ire/git_template/blob/master/template/hooks/change_detector.sh
#  - https://github.com/renatius-de/git/blob/master/template/hooks/base/change_detector.sh
has_changed() {
    local monitored_paths=("$@")
    local against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
    local changed=0

    case "${HOOK_TYPE}" in
        post-commit)
            git rev-parse --verify HEAD^ > /dev/null 2>&1 && against=HEAD^
            changed="$(git diff-tree "${against}" 'HEAD' --stat -- "${monitored_paths[*]}" | wc -l)"
            ;;
        post-checkout | post-merge )
            if [[ "$(git reflog | wc -l)" == 1 ]]; then
                changed=1
            else
                changed="$(git diff 'HEAD@{1}' --stat -- "${monitored_paths[*]}" | wc -l)"
            fi
            ;;
        pre-commit)
            git rev-parse --verify HEAD >/dev/null 2>&1 && against=HEAD
            changed="$(git diff-index --name-status "${against}" -- "${monitored_paths[*]}" | wc -l)"
            ;;
        *)
            ;;
    esac

    [[ ${changed} != 0 ]]
}

run_scripts() {
    for script in "${INCLUDES[@]:-}"; do
        "${script}" "$@"; track_result
    done

    return "${RESULT}"
}

track_result() {
    local last_result="$?"

    RESULT=$((RESULT + last_result))
}
