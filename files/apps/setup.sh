source @bashLib@

nix_config="${HOME}/.nix-config"

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
if ! _is_nixos || _is_root; then
    _clone "nix-config" git@github.com:Gerschtli/nix-config.git "${nix_config}"
fi

if ! _is_root; then
    if _read_boolean "Install atom-config repo?"; then
        if [[ -e "${HOME}/.atom" ]]; then
            mv -v "${HOME}/.atom" "${HOME}/.atom.bak"
        fi

        _clone "atom-config" git@github.com:Gerschtli/atom-config.git "${HOME}/.atom"
    fi

    if _read_boolean "Install gnupg-setup repo?"; then
        _clone "gnupg repo" gitea@git.tobias-happ.de:Gerschtli/gnupg-setup.git "${HOME}/.gnupg-setup"

        if _read_boolean "Install password-store?"; then
            _clone "password store" gitea@git.tobias-happ.de:Gerschtli/pass.git "${HOME}/.password-store"
        fi
    fi

    if _read_boolean "Install files?"; then
        _clone "files" git@github.com:Gerschtli/files.git "${HOME}/.files"
    fi
fi

_clone "age-bak" gitea@git.tobias-happ.de:Gerschtli/age-bak.git "${HOME}/.age-bak"

_log "Change permissions of ~/.age-bak..."
chmod -v 0700 "${HOME}/.age-bak"

if [[ ! -e "${HOME}/.age" ]]; then
    _log "Link ~/.age to ~/.age-bak..."
    ln -snv  "${HOME}/.age-bak" "${HOME}/.age"
fi


# preparation for non nixos systems
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Set priority of installed nix package..."
    nix-env --set-flag priority 1000 nix
fi

# set up cachix (skip nixos for now)
if ! _is_nixos && ! _is_root; then
    _log "Set up cachix..."
    cachix use gerschtli
    cachix use nix-on-droid
fi

# installation
if _is_nixos && _is_root; then
    hostname=$(_read_enum "Enter hostname" krypton neon xenon)

    _log "Run nixos-rebuild switch..."
    nixos-rebuild switch --keep-going --flake "${nix_config}#${hostname}"
elif [[ "${USER}" == "nix-on-droid" ]]; then
    _log "Run nix-on-droid switch..."
    nix-on-droid switch --flake "${nix_config}#oneplus5"
elif ! _is_nixos && ! _is_root; then
    _log "Build home-manager activationPackage..."
    nix build "${nix_config}#homeConfigurations.${USER}@$(hostname).activationPackage"

    _log "Run activate script..."
    HOME_MANAGER_BACKUP_EXT=hm-bak ./result/activate

    rm -v result
fi


# clean up
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Uninstall manual installed nix package..."
    nix-env --uninstall nix
fi

echo
