#! /usr/bin/env bash
set -euo pipefail

# Always work from the root of the repo.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR"/.. && pwd)"
cd "$ROOT_DIR"

export COMPOSE_PROJECT_NAME="mock_proxy"
docker-compose --file deployments/docker-compose.yml down
