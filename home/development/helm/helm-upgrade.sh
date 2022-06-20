if [[ $# -lt 2 ]]; then
    >&2 echo "USAGE: $0 <RELEASE NAME> <APP VERSION> [-v]"
    exit 2
fi

release_name="${1}"
app_version="${2}"
verbose=
separate_namespace=
if [[ "${3:-}" == "-v" ]]; then
    verbose=1
fi

if [[ "${release_name}" =~ ^integration- ]]; then
    echo "deploy to integration environment"
elif [[ "${release_name}" =~ ^tobhap- ]]; then
    separate_namespace=1
else
    >&2 echo "invalid release name: ${release_name}"
    exit 2
fi

chart_directory="container/$(basename "$(pwd)")"
if [[ ! -d "$(pwd)/${chart_directory}" || ! -r "$(pwd)/${chart_directory}/Chart.yaml" ]]; then
    >&2 echo "no valid chart directory found: ${chart_directory}"
    exit 2
fi

helm_extra_options=()
if [[ -n ${separate_namespace} ]]; then
    helm_extra_options+=(--values "${chart_directory}/values.env.autotest.yaml")
fi


if [[ -n ${verbose} ]]; then
    set -x
fi

helm upgrade --install \
    --values "${chart_directory}/values.integration.yaml" \
    "${helm_extra_options[@]}" \
    --set "appVersion=${app_version}" \
    --kube-context integration --namespace integration \
    "${release_name}" \
    "${chart_directory}"
