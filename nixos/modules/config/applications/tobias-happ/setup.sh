#! /usr/bin/env nix-shell
#! nix-shell -i bash -p age coreutils curl findutils git gnugrep gnused hostname jq openssh

{ # prevent execution if this script was only partially downloaded
set -euo pipefail

@bashLibContent@

nixos="/etc/nixos"
nixos_hm="${nixos}/home-manager-configurations"
dotfiles="${HOME}/.dotfiles"
dotfiles_hm="${dotfiles}/home-manager/home-manager-configurations"

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

_exit_if_new_device() {
    if [[ -n "${NEW_DEVICE}" ]]; then
        _log "Please set up your nixos/home-manager configurations and rerun this script in cleanup mode!"
        echo
        exit
    fi
}

_last_steps() {
    if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
        _log "Uninstall manual installed nix package..."
        nix-env --uninstall nix
    fi

    if [[ -d "${dotfiles}" ]]; then
        _log "Setup dotfiles..."
        "${dotfiles}/bootstrap.sh"
    fi

    echo
}


NEW_DEVICE=
mode=$(_read_enum "If you do not want to run the whole script, specify the mode" new-device cleanup "")
if [[ "${mode}" = "new-device" ]]; then
    NEW_DEVICE=1
elif [[ "${mode}" = "cleanup" ]]; then
    _last_steps
    exit
fi


# generate ssh key and show
echo
ssh-keygen -f ~/.ssh/id_rsa -N "" -q || true
_log "Copy link to ssh key or ssh key itself, add in github and gitea:"
echo
cat "${HOME}/.ssh/id_rsa.pub"
echo
curl --silent --form "file=@${HOME}/.ssh/id_rsa.pub" https://file.io | jq --raw-output .link
echo

# pause script
read -sr -n 1 -p "$(echo -e "${PURPLE}Press any key to continue...${RESET}")"
echo

# clone repos
if _is_nixos && _is_root; then
    if _read_boolean "Create backup of ${nixos} and clone configurations?"; then
        mv -v "${nixos}"{,.bak}
        _clone "nixos" git@github.com:Gerschtli/nixos-configurations.git "${nixos}"
    fi

    _clone "home-manager-configurations" git@github.com:Gerschtli/home-manager-configurations.git "${nixos_hm}"
fi

if ! _is_root && ( ! _is_nixos || _read_boolean "Install dotfiles?" ); then
    _clone "dotfiles" git@github.com:Gerschtli/dotfiles.git "${dotfiles}"

    if ! _is_nixos; then
        _clone "home-manager-configurations" git@github.com:Gerschtli/home-manager-configurations.git "${dotfiles_hm}"
    fi

    if _read_boolean "Install gpg repo?"; then
        _clone "gpg repo" gitea@git.tobias-happ.de:Gerschtli/gpg.git "${dotfiles}/gpg"

        if _read_boolean "Install password-store?"; then
            _clone "password store" gitea@git.tobias-happ.de:Gerschtli/pass.git "${HOME}/.password-store"
        fi
    fi
fi

_clone "age-bak" gitea@git.tobias-happ.de:Gerschtli/age-bak.git "${HOME}/.age-bak"

_log "Change permissions of ~/.age-bak..."
chmod -v 0700 "${HOME}/.age-bak"

if _read_boolean "Create ~/.age/key.txt?"; then
    _log "age" "generate age key"
    mkdir -p "${HOME}/.age"
    age-keygen -o "${HOME}/.age/key.txt"

fi


if _is_nixos && _is_root; then
    _log "Setup nix-channels..."
    parameter=$(_read_enum "Enter setup-nix-channels arg" --nixos --small)
    "${nixos_hm}/bin/setup-nix-channels" "${parameter}"
elif ! _is_nixos && ! _is_root; then
    _log "Setup nix-channels..."
    parameter=$(_read_enum "Enter setup-nix-channels arg" --android --non-nixos)
    "${dotfiles_hm}/bin/setup-nix-channels" "${parameter}"
fi


if [[ -f "${HOME}/.nix-channels" ]]; then
    _log "Update nix-channels..."
    nix-channel --update
fi


if _is_nixos && _is_root; then
    _exit_if_new_device

    parameter=$(_read_enum "Enter hostname" argon krypton neon xenon)
    ln -vsnf "${nixos}/configuration-${parameter}.nix" "${nixos}/configuration.nix"
    nixos-rebuild switch || _read_boolean "Was nixos-rebuild successful?"
elif ! _is_nixos && ! _is_root; then
    home_file="${dotfiles_hm}/home-files/$(hostname)/$(whoami).nix"

    if [[ "${USER}" == "nix-on-droid" ]]; then
        _log "Link home.nix file..."
        ln -vsnf "${home_file}" "${HOME}/.config/nixpkgs/home.nix"

        _log "Link nix-on-droid.nix file..."
        ln -vsnf "${dotfiles}/nix-on-droid/nix-on-droid.nix" "${HOME}/.config/nixpkgs/nix-on-droid.nix"

        _log "Run nix-on-droid switch..."
        nix-on-droid switch --verbose
    else
        if [[ -z "${NIX_PATH}" ]]; then
            export NIX_PATH="${HOME}/.nix-defexpr/channels"
        fi

        if ! _available home-manager; then
            _log "Install home-manager..."
            nix-shell '<home-manager>' -A install
        fi

        if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
            _log "Set priority of installed nix package..."
            nix-env --set-flag priority 1000 nix
        fi

        _exit_if_new_device

        _log "Run home-manager switch..."
        home-manager switch -b hm-bak -f "${home_file}"
    fi
fi

_last_steps

}
