#!/usr/bin/env zsh

set -euo pipefail

direction="${1:-next}"
focused_window="$(aerospace list-windows --focused --format $'%{window-id}\t%{app-bundle-id}')"

IFS=$'\t' read -r focused_window_id app_bundle_id <<< "$focused_window"
[[ -n "$focused_window_id" && -n "$app_bundle_id" ]] || exit 0

window_ids=("${(@f)$(aerospace list-windows --monitor all --app-bundle-id "$app_bundle_id" --format '%{window-id}')}" )
(( ${#window_ids} > 1 )) || exit 0

focused_index=0
for (( index = 1; index <= ${#window_ids}; index++ )); do
  if [[ "${window_ids[$index]}" == "$focused_window_id" ]]; then
    focused_index=$index
    break
  fi
done

(( focused_index > 0 )) || exit 0

case "$direction" in
  next) target_index=$((focused_index % ${#window_ids} + 1)) ;;
  prev) target_index=$(((focused_index - 2 + ${#window_ids}) % ${#window_ids} + 1)) ;;
  *) exit 1 ;;
esac

aerospace focus --window-id "${window_ids[$target_index]}"
