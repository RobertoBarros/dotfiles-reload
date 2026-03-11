#!/usr/bin/env bash

set -euo pipefail

direction="${1:-}"

case "$direction" in
  next)
    step=1
    ;;
  prev)
    step=-1
    ;;
  *)
    echo "usage: $0 <next|prev>" >&2
    exit 1
    ;;
esac

workspaces=(
  1 2 3 4 5 6 7 8 9 10
  C F G K M S V W X Y Z
)




current_workspace="$(aerospace list-workspaces --focused | head -n1)"
workspace_count="${#workspaces[@]}"
current_index=-1

for i in "${!workspaces[@]}"; do
  if [ "${workspaces[$i]}" = "$current_workspace" ]; then
    current_index="$i"
    break
  fi
done

if [ "$current_index" -lt 0 ]; then
  current_index=0
  [ "$step" -gt 0 ] || current_index=$((workspace_count - 1))
fi

for offset in $(seq 1 "$workspace_count"); do
  candidate_index=$(((current_index + step * offset + workspace_count) % workspace_count))
  candidate_workspace="${workspaces[$candidate_index]}"

  if [ "$(aerospace list-windows --workspace "$candidate_workspace" --count)" -gt 0 ]; then
    aerospace workspace "$candidate_workspace"
    exit 0
  fi
done

exit 0
