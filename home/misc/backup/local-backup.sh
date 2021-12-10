source @bashLib@

base_dir="/storage/documents"
directories=(@directories@)

_sync() {
    local command="${1}"

    echo
    for dir in "${directories[@]}"; do
        echo "========== ${dir} =========="
        echo

        if [[ -z ${restore} ]]; then
            ${command} "${dir}" "${hostname}:${base_dir}"
        else
            ${command} "${hostname}:${base_dir}/$(basename "${dir}")" "$(dirname "${dir}")"
        fi

        echo
    done
}

command="rsync @rsyncOptions@"

if _read_boolean "Connect to xenon via local ip?" Y; then
    hostname=private.local.xenon
else
    hostname=private.xenon
fi

if _read_boolean "Do you want to backup your data?" Y; then
    restore=
else
    restore=1
fi

_sync "${command} --dry-run"

if _read_boolean "This was a dry run, do you want to start the sync?" N; then
    _sync "${command}"
fi
