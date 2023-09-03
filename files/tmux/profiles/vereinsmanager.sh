source "${PATH_TO_CONF_DIR}/util/helpers.sh"

ROOT="${HOME}/projects/vereinsmanager"

CMD_PRIMARY="git fm"
CMD_SECONDARY="pnpm run dev"

SIDE_CMDS=( "$(_cmds "docker compose up -d db" "pnpm drizzle-kit studio")" )
