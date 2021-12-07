source @bashLib@

list=(
    ~/.nix-config
    ~/.atom
    ~/.files
    ~/.password-store
)

for dir in "${list[@]}"; do
    if [[ ! -d "${dir}/.git" ]]; then
        continue
    fi

    name="${dir#"${HOME}/"}"

    echo -e "\n[${BLUE}DIR${RESET}] ${name}\n"
    git -C "${dir}" status
    echo
done
