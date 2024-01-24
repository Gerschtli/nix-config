source @bashLib@

nix_config="${HOME}/.nix-config"

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

    if [[ -e "${file}" && -w "${file}" ]] && ( [[ "${ask}" != "1" ]] || _read_boolean "Remove ${file//"${HOME}"/"~"}?" ); then
        _log "migration" "remove ${file//"${HOME}"/"~"}"
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

    nvd diff "${1}" ./result

    rm result
}


if _is_root; then
    _log "Please don't run this script with root!"
    exit 1
fi


# add key
_log "keychain" "add key"
keychain "${HOME}/.ssh/keys/id_rsa.vcs"


# update ubuntu
if _available apt && ! _is_darwin; then
    _log "apt" "update"
    sudo apt update
    _log "apt" "upgrade"
    sudo apt upgrade -y
    _log "apt" "autoclean"
    sudo apt autoclean -y
    _log "apt" "autoremove"
    sudo apt autoremove -y
fi

# update brew
if _available brew && _is_darwin; then
    _log "brew" "update"
    brew update
    _log "brew" "upgrade"
    brew upgrade
fi


# update projects
_pull_changes "nix-config"  "${nix_config}"
_pull_changes "files"       "${HOME}/.files"
_pull_changes "pass"        "${HOME}/.password-store"


# nix updates
# TODO: use scripts defined in home/development/nix
if _is_nixos; then
    _log "nix" "build nixos configuration"
    sudo nixos-rebuild build --flake "${nix_config}"
    _show_result_diff "/nix/var/nix/profiles/system"

    _log "nix" "switch nixos configuration"
    sudo nixos-rebuild switch --flake "${nix_config}"
fi

if [[ "${USER}" == "nix-on-droid" ]] && _available nix-on-droid; then
    _log "nix" "build nix-on-droid configuration"
    nix-on-droid build --flake "${nix_config}#pixel7a"
    _show_result_diff "/nix/var/nix/profiles/nix-on-droid"

    _log "nix" "switch nix-on-droid configuration"
    nix-on-droid switch --flake "${nix_config}#pixel7a"
fi

if ! _is_nixos && _available home-manager; then
    _log "nix" "build home-manager configuration"
    home-manager build --flake "${nix_config}"
    _show_result_diff "${HOME}/.local/state/nix/profiles/home-manager"

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

_migration_remove "${HOME}/.ssh/id_rsa"
_migration_remove "${HOME}/.ssh/id_rsa.pub"
_migration_remove "${HOME}/.ssh/known_hosts.old"
_migration_remove "${HOME}/.gnupg-setup" 1

mapfile -t to_be_removed_pkgs < <(nix-env -q --json | jq -r ".[].pname" | grep -Ev '^(home-manager|nix-on-droid)-path$')
if [[ "${#to_be_removed_pkgs[@]}" -ne 0 ]]; then
    _log "migration" "remove manual installed packages via nix-env"
    nix-env --uninstall "${to_be_removed_pkgs[@]}"
fi


# nix cleanup
sudo_for_cleanup=
if _is_nixos; then
    sudo_for_cleanup=sudo
fi

if ! _has_unit_enabled "nix-gc.timer"; then
    _log "nix" "nix-collect-garbage"
    ${sudo_for_cleanup} nix-collect-garbage --delete-older-than 14d 2> /dev/null
fi

if ! _has_unit_enabled "nix-optimise.timer" && [[ "${USER}" != "nix-on-droid" ]]; then
    _log "nix" "nix store optimise"
    ${sudo_for_cleanup} nix store optimise
fi
