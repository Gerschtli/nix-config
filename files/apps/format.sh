shopt -s globstar

DIR="${1-.}"

echo "format in directory: $(realpath "${DIR}")"

echo "run nixpkgs-fmt"
nixpkgs-fmt "${DIR}"/**/*.nix

echo "run statix"
statix fix "${DIR}"
