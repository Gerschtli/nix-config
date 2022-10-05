if [[ $# -lt 2 ]]; then
    >&2 echo "USAGE: $0 <RELEASE NAME> <APP VERSION>"
    exit 2
fi

release_name="${1}"
app_version="${2}"
separate_namespace=
env=integration

if [[ "${release_name}" =~ ^stage- ]]; then
    echo "deploy to stage environment"
    env=stage
elif [[ "${release_name}" =~ ^integration- ]]; then
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


set -x

helm upgrade --install \
    --reset-values \
    --values "${chart_directory}/values.${env}.yaml" \
    "${helm_extra_options[@]}" \
    --set "appVersion=${app_version}" \
    --kube-context "${env}" --namespace "${env}" \
    "${release_name}" \
    "${chart_directory}"
