dev_shell="${1:-}"

_log() {
    echo ">> $*"
}

_log "Write .envrc"
# shellcheck disable=SC2016
echo 'eval "$(lorri direnv)"' > .envrc

_log "Write shell.nix"
echo "(builtins.getFlake \"nix-config\").devShells.\${builtins.currentSystem}.${dev_shell}" > shell.nix

_log "Allow .envrc"
direnv allow

_log "Run lorri watch --once"
lorri watch --once
