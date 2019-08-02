source "${PATH_TO_CONF_DIR}/util/helpers.sh"

ROOT="${HOME}/projects/betting-game-backend"

CMD_PRIMARY="git fm"
CMD_SECONDARY="$(_cmds \
    "nixops/manage dev start" \
    "nixops/manage dev ssh bgb" \
    "journalctl -xef" \
)"
