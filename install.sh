#!/usr/bin/env bash
set -euo pipefail

./scripts/install_dependencies.sh
./scripts/link_configs.sh
./scripts/reload_deamons.sh
echo "=> Installation complete."
