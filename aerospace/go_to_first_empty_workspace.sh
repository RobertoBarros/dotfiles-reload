#!/usr/bin/env bash

set -euo pipefail

workspaces=(
  1 2 3 4 5 6 7 8 9 10
  G K M S W X Y
)

for workspace in "${workspaces[@]}"; do
  if [ "$(aerospace list-windows --workspace "$workspace" --count)" -eq 0 ]; then
    aerospace workspace "$workspace"
    exit 0
  fi
done

exit 0
