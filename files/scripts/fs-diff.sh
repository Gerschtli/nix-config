#!/usr/bin/env bash
set -euo pipefail

IGNORES_FILE="$1"

OLD_TRANSID=$(sudo btrfs subvolume find-new /btrfs/root-blank 9999999)
OLD_TRANSID=${OLD_TRANSID#transid marker was }

btrfs subvolume find-new "/btrfs/root" "$OLD_TRANSID" \
    | sed '$d' \
    | cut -f17- -d' ' \
    | sort --unique \
    | while read path; do
        path="/$path"

        if grep -q "^$path\$" "$IGNORES_FILE"; then
            continue
        fi

        if [ -L "$path" ]; then
            link_target="$(realpath "$path")"
            if ! [[ "$link_target" =~ ^(/nix/store|/persist)/* ]]; then
                echo "$path -> $link_target"
            fi
        elif [ -d "$path" ]; then
            : # The path is a directory, ignore
        elif ! [[ "$path" =~ ^(/home/tobias|/root)/.(compose-)?cache/ ]]; then
            echo "$path"
        fi
    done
