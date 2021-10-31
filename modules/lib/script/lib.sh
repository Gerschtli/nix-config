RESET="\033[0m"
BOLD="\033[1m"
# shellcheck disable=SC2034
GREEN="\033[32m"
# shellcheck disable=SC2034
BLUE="\033[34m"
PURPLE="\033[35m"

_ask() {
    local prompt="${1}"
    local default="${2^^}"

    _cap_if_default() {
        local low="${1,,}"
        local cap="${1^^}"

        [[ "${default}" = "${cap}" ]] && echo "${cap}" || echo "${low}"
    }

    read -rp "$(echo -e "${BOLD}${PURPLE}${prompt} ($(_cap_if_default "y")/$(_cap_if_default "n"))${RESET} ")" answer

    local answer_filled="${answer:-"${default}"}"

    if [[ "${answer_filled^^}" =~ (Y|N) ]]; then
        [[ "${answer_filled^^}" = "Y" ]]
    else
        _ask "${@}"
    fi
}

_available() {
    hash "${1}" > /dev/null 2>&1
}

_is_root() {
    [[ $(id -u) == 0 ]]
}
