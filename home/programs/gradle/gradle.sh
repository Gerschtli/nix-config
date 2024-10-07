EXECUTABLE=gradle

if [[ -f gradlew ]]; then
    [[ -x gradlew ]] || chmod -v +x gradlew

    EXECUTABLE=./gradlew
fi

exec "${EXECUTABLE}" "$@"
