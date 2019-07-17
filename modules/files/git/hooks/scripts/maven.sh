#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

BUILD_FILE="${PWD}/pom.xml"

check() {
    mvn test integration-test; track_result
}

if has_command_and_file mvn "${BUILD_FILE}"; then
    case "${HOOK_TYPE}" in
        pre-push) check ;;
    esac
fi

exit ${RESULT}
