#!/usr/bin/env bash
# Pin release.json to the boat CLI release that boat.dev serves on the prod
# channel (the same one `curl -fsSL https://boat.dev/install | sh` installs).
set -euo pipefail
cd "$(dirname "$0")"

version=$(curl -fsSL 'https://boat.dev/api/boat/cli/version?platform=darwin-arm64&channel=prod' | jq -r .version)
url="https://github.com/ariana-dot-dev/agent-server/releases/download/boat-cli-v$version/boat-darwin-arm64"
hash=$(nix store prefetch-file --json "$url" | jq -r .hash)

jq -n --arg version "$version" --arg hash "$hash" '{$version, $hash}' >release.json
echo "boat $version ($hash)"
