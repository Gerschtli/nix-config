FILE="${1}"

if ! grep "DB_FOOTER" "${FILE}" &> /dev/null; then
    exit
fi

REPLACE=
if [[ "$(git branch-name)" =~ ^feature/(CTMSATOC-[0-9]*).*$ ]]; then
    REPLACE="Issue: ${BASH_REMATCH[1]}"
fi

sed -i -e "s#DB_FOOTER#${REPLACE}#" "${FILE}"
