CONF_NAME="${1}"
PATH_TO_CONF_DIR="@tmuxProfiles@"
WORK_DIRECTORIES=(@workDirectories@)
CONF="${PATH_TO_CONF_DIR}/${CONF_NAME}.sh"
ONLY_FETCH=
PRESET=

[[ "${2:-}" = "--only-fetch" ]] && ONLY_FETCH=1

_check_requirements() {
    [[ -z "${TMUX}" || -z "${TMUX_PANE}" ]] && echo "command needs to be executed in tmux session" && exit 1

    # shellcheck disable=SC2157
    if [[ -r "${CONF}" ]]; then
        # shellcheck disable=SC1090
        source "${CONF}"
    elif [[ -d "${HOME}/projects/${CONF_NAME}" ]]; then
        ROOT="${HOME}/projects/${CONF_NAME}"
        PRESET="git-single"
    elif [[ "${#WORK_DIRECTORIES}" -gt 0 ]]; then
        for work_dir in "${WORK_DIRECTORIES[@]}"; do
            if [[ -d "${HOME}/projects/${work_dir}/${CONF_NAME}" ]]; then
                ROOT="${HOME}/projects/${work_dir}/${CONF_NAME}"
                PRESET="git-single"
                break
            fi
        done
    else
        echo "neither ${CONF} nor projects named ${CONF_NAME} do not exist"
        exit 2
    fi
}

_process_profile() {
    ROOT="${ROOT:-${HOME}}"

    [[ ! -r "${ROOT}" ]] && echo "directory is not readable" && exit 1

    CMD_PRIMARY="${CMD_PRIMARY:-}"
    CMD_SECONDARY=""
    SIDE_CMDS=("${SIDE_CMDS[@]}")

    if [[ -n "${ONLY_FETCH}" ]]; then
        PRESET="git-single"
    fi

    if [[ "${PRESET}" = "git-single" ]]; then
        CMD_PRIMARY="git fm"
        SIDE_CMDS=()
    fi

    if [[ -f "${ROOT}/.envrc" ]]; then
        NIX_CMD="alias refresh-shell > /dev/null && refresh-shell"
    fi
}

_send_commands() {
    local index="${1}"
    local commands="${2}"

    tmux send-keys -t ":.${index}" "cd ${ROOT}" C-m "${NIX_CMD:-}" C-m "clear" C-m

    if [[ -n "${commands}" ]]; then
        local IFS=":"
        for cmd in ${commands}; do
            tmux send-keys -t ":.${index}" "${cmd}" C-m
        done
    fi
}

_arrange_panes() {
    local list_panes_file
    list_panes_file="$(mktemp)"
    tmux list-panes > "${list_panes_file}"
    [[ $(wc -l "${list_panes_file}") != 1 ]] && tmux kill-pane -a -t "${TMUX_PANE}"
    rm -f "${list_panes_file}"

    local index=1
    _send_commands "${index}" "${CMD_PRIMARY}"
    for cmds in "${SIDE_CMDS[@]}"; do
        index=$((index + 1))
        tmux split-window
        _send_commands "${index}" "${cmds}"
    done

    tmux select-layout main-horizontal

    if [[ -n "${CMD_SECONDARY}" ]]; then
        tmux select-pane -t :.1
        tmux split-window -h
        _send_commands 2 "${CMD_SECONDARY}"
    fi

    tmux select-pane -t :.1
    tmux rename-window "${CONF_NAME}"
}

_check_requirements
_process_profile
_arrange_panes
