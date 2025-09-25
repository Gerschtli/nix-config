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

if _is_root; then
    _log "Please don't run this script with root!"
    exit 1
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
_clone "nix-config" git@github.com:Gerschtli/nix-config.git "${nix_config}"

if _read_boolean "Install gnupg-setup repo?"; then
    _clone "gnupg repo" gitea@git.tobias-happ.de:Gerschtli/gnupg-setup.git "${HOME}/.gnupg-setup"

    if _read_boolean "Install password-store?"; then
        _clone "password store" gitea@git.tobias-happ.de:Gerschtli/pass.git "${HOME}/.password-store"
    fi
fi

if _read_boolean "Install files?"; then
    _clone "files" git@github.com:Gerschtli/files.git "${HOME}/.files"
fi

_clone "age-bak" gitea@git.tobias-happ.de:Gerschtli/age-bak.git "${HOME}/.age-bak"

_log "Change permissions of ~/.age-bak..."
chmod -v 0700 "${HOME}/.age-bak"

if [[ ! -e "${HOME}/.age" ]]; then
    _log "Link ~/.age to ~/.age-bak..."
    ln -snv .age-bak "${HOME}/.age"
fi

if _is_nixos && _read_boolean "Set up age keys for root?"; then
    _log "Copy ~/.age-bak/key.txt to /root..."
    sudo mkdir -vp "/root/.age-bak"
    sudo chmod -v 0700 "/root/.age-bak"
    sudo cp -v "${HOME}/.age-bak/key.txt" "/root/.age-bak/key.txt"
    sudo chown root:root "/root/.age-bak/key.txt"

    if ! sudo test -e "/root/.age"; then
        _log "Link /root/.age to /root/.age-bak..."
        sudo ln -snv .age-bak "/root/.age"
    fi
fi

# preparation for non nixos systems
if nix-env -q --json | jq ".[].pname" | grep '"nix"' > /dev/null; then
    _log "Set priority of installed nix package..."
    nix-env --set-flag priority 1000 nix
fi


# installation
if _is_nixos; then
    hostname=$(_read_enum "Enter hostname" argon krypton neon xenon)

    _log "Run sudo nixos-rebuild switch..."
    sudo nixos-rebuild \
      switch \
      --option extra-substituters "https://gerschtli.cachix.org" \
      --option extra-trusted-public-keys "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0=" \
      --keep-going \
      --flake "${nix_config}#${hostname}" || :

    _log "Don't forget to set passwd for tobias and root!"
    _log "It may be required to set up an age key for root:"
    _log "  age-keygen -o ~/.age/key.txt"
elif [[ "${USER}" == "nix-on-droid" ]]; then
    _log "Run nix-on-droid switch..."
    nix-on-droid switch \
      --option extra-substituters "https://gerschtli.cachix.org" \
      --option extra-trusted-public-keys "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0=" \
      --option extra-substituters "https://nix-on-droid.cachix.org" \
      --option extra-trusted-public-keys "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=" \
      --flake "${nix_config}#pixel9"
else
    _log "Build home-manager activationPackage..."
    nix build \
      --extra-experimental-features "nix-command flakes" \
      --option extra-substituters "https://gerschtli.cachix.org" \
      --option extra-trusted-public-keys "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0=" \
      "${nix_config}#homeConfigurations.${USER}@$(hostname).activationPackage"

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
