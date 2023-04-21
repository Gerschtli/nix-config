if [[ $# -lt 1 ]]; then
    >&2 echo "USAGE: $0 <ENVIRONMENT> [--deps-build]"
    exit 2
fi

environment="${1}"

project_name="$(basename "$(pwd)")"
release_name="${environment}-${project_name}"
app_version="$(git branch-name | sed 's,^.*/,,')-$(git rev-parse HEAD | head -c7)"

if [[ "${2:-}" == "--deps-build" ]]; then
    helm dependency build "container/${project_name}"
fi

helm-upgrade "${release_name}" "${app_version}" --wait
