source @completionLib@

for module in "@directoryDestination@/"*; do
    _search_and_append_by_prefix_and_suffix "${module}/keys/id_rsa." ".pub"
done

_arguments "*:ssh keys:(${list[*]})"
