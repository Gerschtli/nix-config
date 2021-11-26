unhash -dm "*"

_set-hashes() {
    local directories
    typeset -A directories

    local dotfiles="${HOME}/.dotfiles"
    local home_manager="${dotfiles}/home-manager/home-manager-configurations"

    directories=(
        "dotfiles" "${dotfiles}"
        "gpg" "${dotfiles}/gpg"
        "home-manager" "${home_manager}"
    )

    if [[ $(id -u) == 0 ]]; then
        local nixos="/etc/nixos"
        local home_manager_nixos="${nixos}/home-manager-configurations"

        directories+=(
           "nixos" "${nixos}"
           "home-manager" "${home_manager_nixos}"
        )
    fi

    local name
    for name in ${(k)directories}; do
        [[ -d "${directories[$name]}" ]] && hash -d "${name}"="${directories[$name]}"
    done

    local projects="${HOME}/projects"

    if [[ -d "${projects}" && -z "$(find "${projects}" -prune -empty)" ]]; then
        local i
        for i in "${projects}"/*(/); do
            hash -d "p-$(basename ${i})"="${i}"
        done

        if [[ -n "${WORK_DIRECTORY}" && -d "${projects}/${WORK_DIRECTORY}"
            && -z "$(find "${projects}/${WORK_DIRECTORY}" -prune -empty)" ]]; then
            local j
            for j in "${projects}/${WORK_DIRECTORY}"/*(/); do
                hash -d "w-$(basename ${j})"="${j}"
            done
        fi
    fi
}

_set-hashes

unset -f _set-hashes
