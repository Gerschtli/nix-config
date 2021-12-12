source @bashLib@

nix_config="${HOME}/.nix-config"

_get_sudo_prefix() {
    if ! _is_root; then
        echo "sudo"
    fi
}

_has_unit_enabled() {
    [[ "$(systemctl is-enabled "${1}" 2> /dev/null)" == "enabled" ]]
}

_log() {
    echo
    echo -e "[${YELLOW}${BOLD}${1}${RESET}] ${BOLD}${2}${RESET}"
    echo
}

_migration_remove() {
    local file="${1}"
    local ask="${2:-}"

    if [[ -e "${file}" && -w "${file}" ]] && ( [[ "${ask}" != "1" ]] || _read_boolean "Remove ${file}?" ); then
        _log "migration" "remove ${file}"
        rm -vrf "${file}"
    fi
}

_pull_changes() {
    if [[ -d "${2}" && -w "${2}" ]]; then
        _log "pull changes" "update ${1} project"
        git -C "${2}" pull --prune
    fi
}

_show_result_diff() {
    echo

    nix store diff-closures "${1}" ./result

    rm result
}


# add key
if _available keychain; then
    _log "keychain" "add key"
    keychain "${HOME}/.ssh/keys/id_rsa.vcs"
else
    _log "ssh-agent" "add key"

    key="${HOME}/.ssh/keys/id_rsa.vcs"
    if ! ssh-add -l | grep " ${key} " > /dev/null 2>&1; then
        ssh-add "${key}"
    fi
fi


# update ubuntu
if _available apt; then
    _log "apt" "update"
    "$(_get_sudo_prefix)" apt update
    _log "apt" "upgrade"
    "$(_get_sudo_prefix)" apt upgrade -y
    _log "apt" "autoclean"
    "$(_get_sudo_prefix)" apt autoclean -y
    _log "apt" "autoremove"
    "$(_get_sudo_prefix)" apt autoremove -y
fi


# update projects
_pull_changes "nix-config"  "${nix_config}"
_pull_changes "atom"        "${HOME}/.atom"
_pull_changes "files"       "${HOME}/.files"
_pull_changes "pass"        "${HOME}/.password-store"


# nix updates
# TODO: use scripts defined in home/development/nix
if _is_nixos && _is_root; then
    _log "nix" "build nixos configuration"
    nixos-rebuild build --keep-going --flake "${nix_config}"
    _show_result_diff "/run/current-system"

    _log "nix" "switch nixos configuration"
    nixos-rebuild switch --keep-going --flake "${nix_config}"
fi

if [[ "${USER}" == "nix-on-droid" ]] && _available nix-on-droid; then
    _log "nix" "build nix-on-droid configuration"
    nix-on-droid build --flake "${nix_config}#oneplus5"
    _show_result_diff "/nix/var/nix/profiles/nix-on-droid"

    _log "nix" "switch nix-on-droid configuration"
    nix-on-droid switch --flake "${nix_config}#oneplus5"
fi

if ! _is_nixos && ! _is_root && _available home-manager; then
    _log "nix" "build home-manager configuration"
    home-manager build --flake "${nix_config}"
    _show_result_diff "/nix/var/nix/profiles/per-user/${USER}/home-manager"

    _log "nix" "switch home-manager configuration"
    home-manager switch --flake "${nix_config}" -b hm-bak
fi


# general migrations
if [[ ! -f "${HOME}/.age/key.txt" || -L "${HOME}/.age" ]] && _read_boolean "Generate ~/.age/key.txt?"; then
    if [[ -L "${HOME}/.age" ]]; then
        rm -v "${HOME}/.age"
    fi

    mkdir -p "${HOME}/.age"
    age-keygen -o "${HOME}/.age/key.txt" 2>&1 |
        sed -e "s,^Public key: \(.*\)\$,\n# $(hostname)-${USER} = \"\1\"," |
        tee -a "${nix_config}/.agenix.toml"
else
    _migration_remove "${HOME}/.age-bak" 1
fi

_migration_remove "${HOME}/.ssh-age"
_migration_remove "${HOME}/.ssh/id_rsa"
_migration_remove "${HOME}/.ssh/id_rsa.pub"
_migration_remove "${HOME}/.ssh/known_hosts.old"
_migration_remove "${HOME}/.gnupg-setup" 1

mapfile -t to_be_removed_pkgs < <(nix-env -q --json | jq -r ".[].pname" | grep -Ev '^(home-manager|nix-on-droid)-path$')
if [[ "${#to_be_removed_pkgs[@]}" -ne 0 ]]; then
    _log "migration" "remove manual installed packages via nix-env"
    nix-env --uninstall "${to_be_removed_pkgs[@]}"
fi


# temporary migrations
_migration_remove "${HOME}/.ssh/keys/id_rsa.age"
_migration_remove "${HOME}/.ssh/keys/id_rsa.age.pub"
_migration_remove "${HOME}/.ssh/modules"
_migration_remove "/etc/nixos" 1
_migration_remove "${HOME}/.dotfiles" 1

if [[ -f "${HOME}/.dotfiles-cache" ]]; then
    mapfile -t dotfiles_links < <(sed -e 's/.*://' "${HOME}/.dotfiles-cache")

    _log "migration" "current dotfiles files to remove"
    for dotfiles_link in "${dotfiles_links[@]}"; do
        if [[ -L "${dotfiles_link}" ]]; then
            echo "${dotfiles_link}"
        else
            echo "SKIP ${dotfiles_link} (not a link)"
        fi
    done

    if _read_boolean "Remove all current deployed dotfiles links?"; then
        for dotfiles_link in "${dotfiles_links[@]}"; do
            if [[ -L "${dotfiles_link}" ]]; then
                rm -v "${dotfiles_link}"
            fi
        done

        rm -v "${HOME}/.dotfiles-cache"
    fi
fi


# nix cleanup
# no cleanup for non root users on NixOS
if ! _is_nixos || _is_root; then
    if ! _has_unit_enabled "nix-gc.timer"; then
        _log "nix" "nix-collect-garbage"
        nix-collect-garbage --delete-older-than 14d 2> /dev/null
    fi

    if ! _has_unit_enabled "nix-optimise.timer" && [[ "${USER}" != "nix-on-droid" ]]; then
        _log "nix" "nix-store --optimise"
        nix-store --optimise
    fi
fi
