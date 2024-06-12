FILE="${1}"

if ! grep "DB_FOOTER" "${FILE}" &> /dev/null; then
    exit
fi

REPLACE=
if [[ "$(git branch-name)" =~ ^(mob/)?feature/(CTMSATOC-[0-9]*).*$ ]]; then
    REPLACE="Issue: ${BASH_REMATCH[2]}"
fi

sed -i -e "s#DB_FOOTER#${REPLACE}#" "${FILE}"
