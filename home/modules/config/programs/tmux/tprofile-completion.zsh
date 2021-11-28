source @completionLib@

_directory_writable() {
    unset ROOT
    # shellcheck disable=SC1090
    source "${1}"
    [[ -z "${ROOT}" || -w "${ROOT}" ]]
}

prefix="@tmuxProfiles@/"
suffix=".sh"

for file in "${prefix}"*"${suffix}"; do
    if _directory_writable "${file}"; then
        _clean_path_and_append "${prefix}" "${suffix}" "${file}"
    fi
done

project_directories=("${HOME}/projects/"*)
# shellcheck disable=SC2157
if [[ -n "@workDirectory@" ]]; then
    project_directories+=("${HOME}/projects/@workDirectory@/"*)
fi

for dir in "${project_directories[@]}"; do
    list+=("$(basename "${dir}")")
done

_arguments \
    "1:profiles:(${list[*]})" \
    "2:options:(--only-fetch)"
