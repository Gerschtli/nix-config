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

_pull_changes() {
    if [[ -d "${2}" && -w "${2}" ]]; then
        _log "pull changes" "update ${1} project"
        git -C "${2}" pull --prune
    fi
}

_show_result_diff() {
    echo

    # see https://github.com/madjar/nox/issues/63#issuecomment-303280129
    nox-update --quiet "${1}" result |
        grep -v '\.drv : $' |
        sed 's|^ */nix/store/[a-z0-9]*-||' |
        sort -u || :

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
    nixos-rebuild switch || : # fails randomly because of virtualbox
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
    _show_result_diff "/nix/var/nix/profiles/per-user/tobias/home-manager"

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

if [[ -d "${HOME}/.ssh-age" ]] && _read_boolean "Remove ~/.ssh-age?"; then
    _log "migration" "remove ~/.ssh-age"
    rm -vrf "${HOME}/.ssh-age"
fi

if [[ -f "${HOME}/.ssh/keys/id_rsa.age" || -f "${HOME}/.ssh/keys/id_rsa.age.pub" ]]; then
    _log "migration" "remove ~/.ssh/keys/id_rsa.age*"
    rm -v "${HOME}/.ssh/keys/id_rsa.age"*
fi

if [[ -f "${HOME}/.ssh/id_rsa" || -f "${HOME}/.ssh/id_rsa.pub" ]]; then
    _log "migration" "remove ~/.ssh/id_rsa*"
    rm -v "${HOME}/.ssh/id_rsa"*
fi

if [[ -f "${HOME}/.ssh/known_hosts.old" ]]; then
    _log "migration" "remove ~/.ssh/known_hosts.old"
    rm -v "${HOME}/.ssh/known_hosts.old"
fi

if [[ -d "${HOME}/.ssh/modules" ]]; then
    _log "migration" "remove ~/.ssh/modules"
    rm -vrf "${HOME}/.ssh/modules"
fi

for project in "${nixos}" "${nixos_hm}" "${dotfiles_hm}"; do
    dir="${project}/modules/secrets"
    if [[ -d "${dir}" && -w "${dir}" ]] && _read_boolean "Remove ${dir}?"; then
        _log "migration" "remove ${dir}"
        rm -vrf "${dir}"
    fi
done
