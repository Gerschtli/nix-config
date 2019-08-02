source "${PATH_TO_CONF_DIR}/util/helpers.sh"

ROOT="${HOME}/projects/pveu/frontend"

CMD_PRIMARY="git fm"
CMD_SECONDARY="$(_cmds \
    "cdv" \
    "while ! vst | grep running > /dev/null; do sleep 30; done" \
    "vssh" \
    "cd /var/www/htdocs" \
    "killall gulp" \
    "while true; do npm run watch; done" \
)"

SIDE_CMDS=(
    "$(_cmds "cdv" "vup" "vauto")"
)
