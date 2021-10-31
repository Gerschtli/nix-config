source @hooksLib@

SECRET_FILES="${PWD}/.secret-files"

install() {
    while read -r line; do
        local file="${PWD}/${line}"
        if [[ -e "${file}" ]]; then
            chmod 0640 "${file}"
            # try to set group if group is available
            chgrp secret-files "${file}" 2> /dev/null || :
        fi
    done < "${SECRET_FILES}"
}

if [[ -r "${SECRET_FILES}" && "${HOOK_TYPE}" = @(post-checkout|post-merge) ]]; then
    install
fi

exit "${RESULT}"
