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
            ${command} "${dir}" "${host_name}:${base_dir}"
        else
            ${command} "${host_name}:${base_dir}/$(basename "${dir}")" "$(dirname "${dir}")"
        fi

        echo
    done
}

command="rsync @rsyncOptions@"

if _ask "Connect to xenon via local ip?" Y; then
    host_name=private.local.xenon.wlan
else
    host_name=private.xenon.wlan
fi

if _ask "Do you want to backup your data?" Y; then
    restore=
else
    restore=1
fi

_sync "${command} --dry-run"

if _ask "This was a dry run, do you want to start the sync?" N; then
    _sync "${command}"
fi
