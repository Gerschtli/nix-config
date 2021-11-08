source @bashLib@

list=()

if _is_root; then
    list+=(
        /etc/nixos
        /etc/nixos/modules/secrets
        /etc/nixos/home-manager-configurations
        /etc/nixos/home-manager-configurations/modules/secrets
        /etc/nixos/home-manager-configurations/modules/secrets/ssh/modules/*
    )
fi

list+=(
    ~/.dotfiles
    ~/.dotfiles/gpg
    ~/.dotfiles/home-manager/home-manager-configurations
    ~/.dotfiles/home-manager/home-manager-configurations/modules/secrets
    ~/.dotfiles/home-manager/home-manager-configurations/modules/secrets/ssh/modules/*
    ~/.password-store
    ~/.ssh-age
)

for dir in "${list[@]}"; do
    if [[ ! -d "${dir}/.git" ]]; then
        continue
    fi

    name="${dir#"${HOME}/"}"
    name="${name#*/secrets/}"
    name="${name#/etc/}"

    echo -e "\n[${BLUE}DIR${RESET}] ${name}\n"
    git -C "${dir}" status
    echo
done
