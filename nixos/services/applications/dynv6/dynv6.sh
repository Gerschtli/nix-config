hostname="@dynv6Hostname@"
device="@device@"
token="$(cat "@passwordFile@")"
file="@stateDir@/dynv6.addr6"

if [[ -e "${file}" ]]; then
    old="$(cat "${file}")"
fi

address="$(ip -6 addr list scope global dev "${device}" | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\/[0-9]\+\).*/\1/p' | head -n 1)"

if [[ -z "${address}" ]]; then
    echo "no IPv6 address found"
    exit 1
fi

if [[ "${old:-}" == "${address}" ]]; then
    echo "IPv6 address unchanged"
    exit
fi

# send addresses to dynv6
curl -fsS "http://dynv6.com/api/update?hostname=${hostname}&ipv6=${address}&token=${token}"
curl -fsS "http://ipv4.dynv6.com/api/update?hostname=${hostname}&ipv4=auto&token=${token}"

# save current address
echo "${address}" > "${file}"
