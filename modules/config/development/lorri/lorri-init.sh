shell_name="${1:-}"
force="${2:-}"
shell_path="@nixProfilesDir@/${shell_name}.nix"

_log() {
    echo ">> $*"
}

if [[ ( ! -f shell.nix || "${force}" == "--force" ) && -f "${shell_path}" ]]; then
    _log "Link shell.nix"
    ln -snfv "${shell_path}" shell.nix
fi

_log "Run lorri init"
lorri init

_log "Allow .envrc"
direnv allow

_log "Run lorri watch --once"
lorri watch --once
