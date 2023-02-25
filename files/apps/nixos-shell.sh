source @bashLib@

if [[ -e nixos.qcow2 ]] && _read_boolean "Previous state found, delete it?"; then
    rm -v nixos.qcow2
    echo
fi

nixos-shell --flake ".#nixos-shell-vm"
