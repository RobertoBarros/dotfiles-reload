#!/usr/bin/env bash

set -euo pipefail

mode="${1:-focus}"

workspaces=(
  1 2 3 4 5 6 7 8 9 10
)

find_first_empty_workspace() {
  for workspace in "${workspaces[@]}"; do
    if [ "$(aerospace list-windows --workspace "$workspace" --count)" -eq 0 ]; then
      printf '%s\n' "$workspace"
      return 0
    fi
  done

  return 1
}

case "$mode" in
  focus)
    if workspace="$(find_first_empty_workspace)"; then
      aerospace workspace "$workspace"
    fi
    ;;
  move)
    if workspace="$(find_first_empty_workspace)"; then
      aerospace move-node-to-workspace "$workspace"
      aerospace workspace "$workspace"
    fi
    ;;
  *)
    echo "usage: $0 [focus|move]" >&2
    exit 1
    ;;
esac

exit 0
