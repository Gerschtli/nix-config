source @completionLib@

_search_and_append_by_prefix_and_suffix "@keysDirectory@/id_rsa." ".pub"

_arguments "*:ssh keys:(${list[*]})"
