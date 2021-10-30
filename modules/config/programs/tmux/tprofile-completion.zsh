_directory_writable() {
    unset ROOT
    # shellcheck disable=SC1090
    source "${1}"
    [[ -z "${ROOT}" || -w "${ROOT}" ]]
}

list=()

prefix="@tmuxProfiles@/"
suffix=".sh"

for file in "${prefix}"*"${suffix}"; do
    if _directory_writable "${file}"; then
        list+=("${${file#"${prefix}"}//"${suffix}"}")
    fi
done

for dir in ~/projects/*; do
    list+=("$(basename "${dir}")")
done

_arguments \
    "1:profiles:(${list[*]})" \
    "2:options:(--only-fetch)"
