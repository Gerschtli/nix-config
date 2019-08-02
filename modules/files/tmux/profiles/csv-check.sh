source "${PATH_TO_CONF_DIR}/util/helpers.sh"

ROOT="${HOME}/Downloads"

SIDE_CMDS=(
    "$(_cmds "ssh pveu.live.db01" "mysql soap")"
    "ssh pveu.live.batch"
)
