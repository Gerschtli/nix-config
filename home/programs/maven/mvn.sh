EXECUTABLE=mvn

if [[ -f mvnw ]]; then
    [[ -x mvnw ]] || chmod -v +x mvnw

    EXECUTABLE=./mvnw
fi

exec "${EXECUTABLE}" "$@"
