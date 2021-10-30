list=()

prefix="@nixProfilesDir@/"
suffix=".nix"

for file in "${prefix}"*"${suffix}"; do
    list+=("${${file#"${prefix}"}//"${suffix}"}")
done

_arguments \
    "1:nix-shell profiles:(${list[*]})" \
    "2:options:(--force)"
