source @completionLib@

_search_and_append_by_prefix_and_suffix "@nixProfilesDir@/" ".nix"

_arguments \
    "1:nix-shell profiles:(${list[*]})" \
    "2:options:(--force)"
