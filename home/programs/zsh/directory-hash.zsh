unhash -dm "*"

_set-hashes() {
    hash -d "nix-config"="${HOME}/.nix-config"

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
