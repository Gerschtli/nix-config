source @bashLib@

list=()

if _is_root; then
    list+=(
        /etc/nixos
        /etc/nixos/home-manager-configurations
    )
fi

list+=(
    ~/.dotfiles
    ~/.dotfiles/gpg
    ~/.dotfiles/home-manager/home-manager-configurations
    ~/.password-store
    ~/.ssh-age
)

for dir in "${list[@]}"; do
    if [[ ! -d "${dir}/.git" ]]; then
        continue
    fi

    name="${dir#"${HOME}/"}"
    name="${name#/etc/}"

    echo -e "\n[${BLUE}DIR${RESET}] ${name}\n"
    git -C "${dir}" status
    echo
done
