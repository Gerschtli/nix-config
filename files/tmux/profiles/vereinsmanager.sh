source "${PATH_TO_CONF_DIR}/util/helpers.sh"

ROOT="${HOME}/projects/vereinsmanager"

CMD_PRIMARY="git fm"

SIDE_CMDS=( "$(_cmds "docker compose up -d db" "pnpm drizzle-kit studio")" )
