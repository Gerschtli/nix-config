# Wrapper for git diff.external: translates git's 7-arg format to sem diff
# Args: path old-file old-hex old-mode new-file new-hex new-mode
exec sem diff --verbose --color always "$2" "$5"
