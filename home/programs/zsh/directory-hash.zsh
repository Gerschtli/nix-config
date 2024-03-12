unhash -dm "*"

_set-hashes() {
    hash -d "nix-config"="${HOME}/.nix-config"

    local projects="${HOME}/projects"

    if [[ -d "${projects}" && -z "$(find "${projects}" -prune -empty)" ]]; then
        local i
        for i in "${projects}"/*(/); do
            hash -d "p-$(basename ${i})"="${i}"
        done

        local workDirectory
        local j
        for workDirectory in "${WORK_DIRECTORY[@]}"; do
            if [[ -d "${projects}/${workDirectory}" && -z "$(find "${projects}/${workDirectory}" -prune -empty)" ]]; then
                for j in "${projects}/${workDirectory}"/*(/); do
                    hash -d "w-$(basename ${j})"="${j}"
                done
            fi
        done
    fi
}

_set-hashes

unset -f _set-hashes
