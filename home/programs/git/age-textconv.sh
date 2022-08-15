FILE="${1:-}"

age --identity "${HOME}/.age/key.txt" --decrypt "${FILE}" 2> /dev/null || echo "encrypted content (something random: ${RANDOM})"
