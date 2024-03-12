FILE="${1}"

if ! grep "DB_PREFIX" "${FILE}" &> /dev/null; then
    exit
fi

REPLACE=
if [[ "$(git branch-name)" =~ ^feature/(CTMSATOC-[0-9]*).*$ ]]; then
    REPLACE="${BASH_REMATCH[1]} "
fi

sed -i -e "s#DB_PREFIX#${REPLACE}#" "${FILE}"
