#!/usr/bin/env bash
set -euo pipefail

path="$1"
dest="/persist$path"

if ! [[ "$path" =~ ^/* ]]; then
    echo "invalid path: $path"
    exit 1
fi

if ! [[ -d "$(dirname "$dest")" ]]; then
    echo "please create $(dirname "$dest") with necessary permissions and ownership"
    exit 2
fi

cp -avr "$path" "$dest"
