source @completionLib@

_search_and_append_by_prefix_and_suffix "@forkDir@/" ""

_arguments \
    "1:modes:(debug dev build test switch)" \
    "*:forks:(${list[*]})"
