#!/usr/bin/env bash

source "${HOOKS_DIR}/helpers/util.sh"

BUILD_FILE="${PWD}/pom.xml"

check() {
    mvn -U -up clean test integration-test package checkstyle:check pmd:check pmd:cpd-check findbugs:check spotbugs:check; track_result
}

if has_command_and_file mvn "${BUILD_FILE}"; then
    case "${HOOK_TYPE}" in
        pre-push) check ;;
    esac
fi

exit ${RESULT}
