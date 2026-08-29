#!/usr/bin/env bash

set -euo pipefail

app_name="${1:?usage: $0 <app-name> <app-bundle-id>}"
app_bundle_id="${2:?usage: $0 <app-name> <app-bundle-id>}"

if aerospace list-windows --all --format '%{app-bundle-id}' | grep -Fx "$app_bundle_id" >/dev/null; then
  open -a "$app_name"
  exit 0
fi

workspaces=(1 2 3 4 5 6 7 8 9 10)
current_workspace="$(aerospace list-workspaces --focused | head -n1)"
workspace_count="${#workspaces[@]}"
current_index=-1

for i in "${!workspaces[@]}"; do
  if [ "${workspaces[$i]}" = "$current_workspace" ]; then
    current_index="$i"
    break
  fi
done

for offset in $(seq 1 "$workspace_count"); do
  candidate_index=$(((current_index + offset + workspace_count) % workspace_count))
  candidate_workspace="${workspaces[$candidate_index]}"

  if [ "$(aerospace list-windows --workspace "$candidate_workspace" --count)" -eq 0 ]; then
    aerospace workspace "$candidate_workspace"
    break
  fi
done

open -a "$app_name"
