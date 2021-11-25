source @bashLib@

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

    if [[ -f "${file}" || -d "${file}" ]] && ( [[ "${ask}" != "1" ]] || _read_boolean "Remove ${file}?" ); then
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

    @nixUnstable@/bin/nix store diff-closures "${1}" result

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
nixos="/etc/nixos"
nixos_hm="${nixos}/home-manager-configurations"
dotfiles="${HOME}/.dotfiles"
dotfiles_hm="${dotfiles}/home-manager/home-manager-configurations"

_pull_changes "nixos"         "${nixos}"
_pull_changes "home-manager"  "${nixos_hm}"
_pull_changes "dotfiles"      "${dotfiles}"
_pull_changes "gpg"           "${dotfiles}/gpg"
_pull_changes "home-manager"  "${dotfiles_hm}"
_pull_changes "pass"          "${HOME}/.password-store"


# dotfiles bootstrap
if [[ -d "${dotfiles}" ]]; then
    _log "dotfiles" "run bootstrap"
    "${dotfiles}/bootstrap.sh"
fi


# nix updates
if [[ -r "${HOME}/.nix-channels" ]] && ! _has_unit_enabled "nixos-upgrade.timer" &&
   [[ $(find /nix/var/nix/profiles/per-user -type l -iname "channels-*" -mtime -7 | wc -l) == 0 ]]; then
    _log "nix" "update nix-channel"
    nix-channel --update
fi

if _is_nixos && _is_root; then
    _log "nix" "build nixos configuration"
    nixos-rebuild build
    _show_result_diff "/run/current-system"

    _log "nix" "switch nixos configuration"
    nixos-rebuild switch --keep-going
fi

if [[ -r "${HOME}/.config/nixpkgs/nix-on-droid.nix" ]] && _available nix-on-droid; then
    _log "nix" "build nix-on-droid configuration"
    nix-on-droid build
    _show_result_diff "/nix/var/nix/profiles/nix-on-droid"

    _log "nix" "switch nix-on-droid configuration"
    nix-on-droid switch
fi

if [[ -r "${HOME}/.config/nixpkgs/home.nix" ]] && _available home-manager; then
    _log "nix" "build home-manager configuration"
    home-manager build
    _show_result_diff "/nix/var/nix/profiles/per-user/${USER}/home-manager"

    _log "nix" "switch home-manager configuration"
    home-manager switch -b hm-bak
fi


# nix cleanup
# no cleanup for non root users on NixOS
if ! _is_nixos || _is_root; then
    if ! _has_unit_enabled "nix-gc.timer"; then
        _log "nix" "nix-collect-garbage"
        nix-collect-garbage --delete-older-than 14d 2> /dev/null
    fi

    if ! _has_unit_enabled "nix-optimise.timer" && [[ "$(whoami)" != "nix-on-droid" ]]; then
        _log "nix" "nix-store --optimise"
        nix-store --optimise
    fi
fi


# migrations
if [[ ! -f "${HOME}/.age/key.txt" ]] && _read_boolean "Generate ~/.age/key.txt?"; then
    mkdir -p "${HOME}/.age"
    age-keygen -o "${HOME}/.age/key.txt"
fi

_migration_remove "${HOME}/.age-bak" 1
_migration_remove "${HOME}/.ssh-age" 1
_migration_remove "${HOME}/.ssh/id_rsa"
_migration_remove "${HOME}/.ssh/id_rsa.pub"
_migration_remove "${HOME}/.ssh/keys/id_rsa.age"
_migration_remove "${HOME}/.ssh/keys/id_rsa.age.pub"
_migration_remove "${HOME}/.ssh/known_hosts.old"
_migration_remove "${HOME}/.ssh/modules"

for project in "${nixos}" "${nixos_hm}" "${dotfiles_hm}"; do
    _migration_remove "${project}/modules/secrets" 1
done
