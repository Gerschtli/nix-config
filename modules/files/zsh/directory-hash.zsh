unhash -dm "*"

PROJECTS="${HOME}/projects"

if [[ -d "${PROJECTS}" ]]; then
    for i in "${PROJECTS}"/*(/); do
        hash -d "p-$(basename ${i})"="${i}"
    done

    if [[ -d "${PROJECTS}/pveu" ]]; then
        for i in "${PROJECTS}/pveu"/*(/); do
            hash -d "w-$(basename ${i})"="${i}"
        done
    fi
fi

unset PROJECTS
