#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

SECRET_FILES="${PWD}/.secret-files"

install() {
    cat "${SECRET_FILES}" | while read -r line; do
        echo $line
        if [[ -e "${PWD}/${line}" ]]; then
            echo chmod
            chmod 0600 "${PWD}/${line}"
        fi
    done
}

echo $PWD
echo $HOOK_TYPE

if [[ -r "${SECRET_FILES}" ]]; then
    case "${HOOK_TYPE}" in
        post-checkout | post-merge) install ;;
    esac
fi

exit ${RESULT}
