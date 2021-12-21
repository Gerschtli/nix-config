dev_shell="${1:-}"
force="${2:-}"

_log() {
    echo ">> $*"
}

if [[ -e .envrc && "${force}" == "--force" ]]; then
    _log "Remove .envrc"
    rm .envrc
fi

if [[ ! -f shell.nix || "${force}" == "--force" ]]; then
    _log "Write shell.nix"
    echo "(builtins.getFlake \"@nixConfigDir@\").devShells.\${builtins.currentSystem}.${dev_shell}" > shell.nix
fi

_log "Run lorri init"
lorri init

_log "Allow .envrc"
direnv allow

_log "Run lorri watch --once"
lorri watch --once
