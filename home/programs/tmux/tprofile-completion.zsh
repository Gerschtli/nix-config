source @completionLib@

PATH_TO_CONF_DIR="@tmuxProfiles@"

_directory_writable() {
    unset ROOT
    # shellcheck disable=SC1090
    source "${1}"
    [[ -z "${ROOT}" || -w "${ROOT}" ]]
}

prefix="${PATH_TO_CONF_DIR}/"
suffix=".sh"

for file in "${prefix}"*"${suffix}"; do
    if _directory_writable "${file}"; then
        _clean_path_and_append "${prefix}" "${suffix}" "${file}"
    fi
done

project_directories=("${HOME}/projects/"*)
work_directories=(@workDirectories@)
for work_dir in "${work_directories[@]}"; do
    project_directories+=("${HOME}/projects/${work_dir}/"*)
done

for dir in "${project_directories[@]}"; do
    list+=("$(basename "${dir}")")
done

_arguments \
    "1:profiles:(${list[*]})" \
    "2:options:(--only-fetch)"
