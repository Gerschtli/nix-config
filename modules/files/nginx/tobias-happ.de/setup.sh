#! /usr/bin/env nix-shell
#! nix-shell -i bash -p coreutils curl findutils git gnugrep gnused hostname jq openssh

{ # prevent execution if this script was only partially downloaded
set -e

RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[33m"
PURPLE="\033[35m"

nixos="/etc/nixos"
nixos_hm="${nixos}/home-manager-configurations"
dotfiles="${HOME}/.dotfiles"
dotfiles_hm="${dotfiles}/home-manager/home-manager-configurations"
secrets_path="modules/secrets"
ssh_path="${secrets_path}/ssh/modules"

_log() {
    echo
    echo -e "${BOLD}${YELLOW}${1}${RESET}"
}

_clone() {
    local name="${1}"
    local url="${2}"
    local directory="${3}"

    if [[ -d "${directory}" ]]; then
        _log "Not cloning ${name} because ${directory} already exists!"
        return
    fi

    _log "Clone ${name}..."
    git clone "${url}" "${directory}"
}

_prompt() {
    local result

    read -p "$(echo -e "\n${BOLD}${PURPLE}${1} (y/n): ${RESET}")" -n1 result
    echo

    case "${result}" in
        y) return 0 ;;
        n) return 1 ;;
        *)
            _prompt "${1}"
            ;;
    esac
}

_get_input() {
    local result
    local text="${1}"
    local options="${@:2}"

    read -p "$(echo -e "\n${BOLD}${PURPLE}${1} (one of ${options// /, }): ${RESET}")" result

    if [[ " ${options[@]} " == *" ${result} "* ]]; then
        echo "${result}"
    else
        _get_input "${text}" ${@:2}
    fi
}

_is_nixos() {
    [[ -f "/etc/NIXOS" ]]
}

_is_root() {
    [[ $(id -u) == 0 ]]
}

_clone_ssh() {
    local directory="${1}"

    for name in private vcs; do
        if [[ "${name}" == "vcs" ]] || _prompt "Install ssh repo ${name}?"; then
            _clone "ssh repo ${name}" gitea@git.tobias-happ.de:Gerschtli/ssh-${name}.git "${directory}/${name}"
        fi
    done
}

_fix_permissions() {
    local secret_files="${1}/.secret-files"

    while read -r line; do
        local file="${1}/${line}"
        if [[ -e "${file}" ]]; then
            chmod 0640 "${file}"
            # try to set group if group is available
            chgrp secret-files "${file}" 2> /dev/null || :
        fi
    done < "${secret_files}"
}


# generate ssh key and show
ssh-keygen -f ~/.ssh/id_rsa -N "" -q || true
_log "Copy link to ssh key or ssh key itself, add in github and gitea:"
echo
cat "${HOME}/.ssh/id_rsa.pub"
echo
curl --silent --form "file=@${HOME}/.ssh/id_rsa.pub" https://file.io | jq --raw-output .link
echo

# pause script
read -p "$(echo -e "${PURPLE}Press any key to continue...${RESET}")" -n1 -s
echo

# clone repos
if _is_nixos && _is_root; then
    if _prompt "Remove ${nixos} and clone configurations?"; then
        rm -rf /etc/nixos
        _clone "nixos" git@github.com:Gerschtli/nixos-configurations.git "${nixos}"
    fi

    secrets_repo_host=$(_get_input "Enter host name for nixos secrets" neon xenon "")
    if [[ "${secrets_repo}" != "" ]]; then
        secrets_repo="secrets-${secrets_repo}-nixos"
        _clone "${secrets_repo}" "gitea@git.tobias-happ.de:Gerschtli/${secrets_repo}.git" "${nixos}/${secrets_path}"
    fi

    _clone "home-manager-configurations" git@github.com:Gerschtli/home-manager-configurations.git "${nixos_hm}"

    _clone_ssh "${nixos_hm}/${ssh_path}"
fi

if ! _is_root && ( ! _is_nixos || _prompt "Install dotfiles?" ); then
    _clone "dotfiles" git@github.com:Gerschtli/dotfiles.git "${dotfiles}"

    if ! _is_nixos; then
        _clone "home-manager-configurations" git@github.com:Gerschtli/home-manager-configurations.git "${dotfiles_hm}"

        _clone_ssh "${dotfiles_hm}/${ssh_path}"
    fi

    if _prompt "Install gpg repo?"; then
        _clone "gpg repo" gitea@git.tobias-happ.de:Gerschtli/gpg.git "${dotfiles}/gpg"

        if _prompt "Install password-store?"; then
            _clone "password store" gitea@git.tobias-happ.de:Gerschtli/pass.git "${HOME}/.password-store"
        fi
    fi
fi


if _is_nixos && _is_root; then
    _log "Setup nix-channels..."
    parameter=$(_get_input "Enter setup-nix-channels arg" --nixos --small)
    ${nixos_hm}/bin/setup-nix-channels ${parameter}
elif ! _is_nixos && ! _is_root; then
    _log "Setup nix-channels..."
    parameter=$(_get_input "Enter setup-nix-channels arg" --android --non-nixos)
    ${dotfiles_hm}/bin/setup-nix-channels ${parameter}
fi


if [[ -f "${HOME}/.nix-channels" ]]; then
    _log "Update nix-channels..."
    nix-channel --update
fi


if _is_nixos && _is_root; then
    parameter=$(_get_input "Enter hostname" argon krypton xenon)
    ln -sf "${nixos}/configuration-${parameter}.nix" "${nixos}/configuration.nix"
    nixos-rebuild switch || _prompt "Was nixos-rebuild successful?"

    for module in "${nixos_hm}/${ssh_path}/"*; do
        _fix_permissions "${module}"
    done
elif ! _is_nixos && ! _is_root; then
    home_file="${dotfiles_hm}/home-files/$(hostname)/$(whoami).nix"

    if [[ "${USER}" == "nix-on-droid" ]]; then
        _log "Link home.nix file..."
        ln -snf "${home_file}" "${HOME}/.config/nixpkgs/home.nix"

        _log "Link nix-on-droid.nix file..."
        ln -snf "${dotfiles}/nix-on-droid/nix-on-droid.nix" "${HOME}/.config/nixpkgs/nix-on-droid.nix"

        _log "Run nix-on-droid switch..."
        nix-on-droid switch --verbose
    else
        if ! hash home-manager 2>&1 > /dev/null; then
            _log "Install home-manager..."
            nix-shell '<home-manager>' -A install
        fi

        if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
            _log "Set priority of installed nix package..."
            nix-env --set-flag priority 1000 nix
        fi

        _log "Run home-manager switch..."
        home-manager switch -b hm-bak -f "${home_file}"

        if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
            _log "Uninstall manual installed nix package..."
            nix-env --uninstall nix
        fi
    fi

    for module in "${dotfiles_hm}/${ssh_path}/"*; do
        _fix_permissions "${module}"
    done
fi


if [[ -d "${dotfiles}" ]]; then
    _log "Setup dotfiles..."
    ${dotfiles}/bootstrap.sh
fi

}
