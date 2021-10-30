list=()

for module in "@directoryDestination@/"*; do
    prefix="${module}/keys/id_rsa."
    suffix=".pub"

    for file in "${prefix}"*"${suffix}"; do
        list+=("${"${file#"${prefix}"}"//"${suffix}"}")
    done
done

_arguments "*:ssh keys:(${list[*]})"
