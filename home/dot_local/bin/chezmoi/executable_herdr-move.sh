#!/bin/zsh
# Move the currently active herdr workspace up/down, or the active tab left/right.
#
# Usage:
#   movedown.sh -d   # move active workspace down one
#   movedown.sh -u   # move active workspace up one
#   movedown.sh -l   # move active tab left one
#   movedown.sh -r   # move active tab right one
#
# Exactly one of -u / -d / -l / -r is required; specifying none is an error.
#
# Uses the herdr Unix socket API:
#   - `herdr pane current` to find the active pane's workspace_id and tab_id
#   - `workspace.list` / `tab.list` to read the ordered workspace/tab lists
#   - `workspace.move` / `tab.move` with {<id>, insert_index} to reorder
#
# insert_index semantics (empirically verified against the herdr server):
#   insert_index is the target position in the FINAL array, offset by one when
#   moving toward a higher index. To land at final position F:
#     - moving to a LOWER index  (up/left,  F < cur_idx): insert_index = F
#     - moving to a HIGHER index (down/right, F > cur_idx): insert_index = F + 1
#   insert_index equal to cur_idx or cur_idx+1 is a no-op; values > len error.
#   Therefore, "one step" moves are:
#     - up/left:   final = cur_idx - 1, insert_index = cur_idx - 1
#     - down/right: final = cur_idx + 1, insert_index = cur_idx + 2

set -euo pipefail

SOCK="${HERDR_SOCK:-$HOME/.config/herdr/herdr.sock}"

direction=""
while getopts ":udlr" opt; do
  case "$opt" in
    u) direction="up" ;;
    d) direction="down" ;;
    l) direction="left" ;;
    r) direction="right" ;;
    \?) echo "error: unknown option: -$OPTARG" >&2; exit 2 ;;
    :)  echo "error: option requires an argument: -$OPTARG" >&2; exit 2 ;;
  esac
done

if [ -z "$direction" ]; then
  echo "error: must specify exactly one of -u (up), -d (down), -l (left), -r (right)" >&2
  echo "usage: $(basename "$0") -u | -d | -l | -r" >&2
  exit 2
fi

# Active pane: workspace_id + tab_id.
pane=$(herdr pane current)
current_ws=$(echo "$pane" | jq -r '.result.pane.workspace_id')
current_tab=$(echo "$pane" | jq -r '.result.pane.tab_id')

# Compute move for a given direction and ordered id list.
# Echoes: "<insert_index> <final_index> <cur_idx> <len>"
# Exits 0 with a no-op message when the element is already at the boundary.
compute_move() {
  local dir="$1" cur_idx="$2" len="$3"
  local final_idx insert_idx

  if [ "$dir" = "up" ] || [ "$dir" = "left" ]; then
    if [ "$cur_idx" -eq 0 ]; then
      echo "already at first position (index 0); nothing to move $dir." >&2
      return 1
    fi
    final_idx=$((cur_idx - 1))
    insert_idx=$final_idx
  else  # down / right
    if [ "$cur_idx" -eq "$((len - 1))" ]; then
      echo "already at last position (index $((len - 1))); nothing to move $dir." >&2
      return 1
    fi
    final_idx=$((cur_idx + 1))
    insert_idx=$((cur_idx + 2))
  fi
  echo "$insert_idx $final_idx $cur_idx $len"
}

if [ "$direction" = "up" ] || [ "$direction" = "down" ]; then
  # --- Workspace move ---
  workspaces=$(echo '{"id":"req_list","method":"workspace.list","params":{}}' | nc -U "$SOCK")
  len=$(echo "$workspaces" | jq '.result.workspaces | length')
  cur_idx=$(echo "$workspaces" | jq -r --arg id "$current_ws" \
    '.result.workspaces | to_entries | .[] | select(.value.workspace_id == $id) | .key')

  if [ -z "$cur_idx" ]; then
    echo "error: current workspace '$current_ws' not found in workspace.list" >&2
    exit 1
  fi

  move=$(compute_move "$direction" "$cur_idx" "$len") || exit 0
  read -r insert_idx final_idx _ _ <<<"$move"

  echo "moving workspace '$current_ws' from index $cur_idx $direction to $final_idx (insert_index=$insert_idx)"
  echo "{\"id\":\"req_move\",\"method\":\"workspace.move\",\"params\":{\"workspace_id\":\"$current_ws\",\"insert_index\":$insert_idx}}" \
    | nc -U "$SOCK" | jq '.result.workspaces | to_entries | map({i:.key, id:.value.workspace_id, label:.value.label})'

else
  # --- Tab move (left/right) ---
  tabs=$(echo "{\"id\":\"req_tabs\",\"method\":\"tab.list\",\"params\":{\"workspace_id\":\"$current_ws\"}}" | nc -U "$SOCK")
  len=$(echo "$tabs" | jq '.result.tabs | length')
  cur_idx=$(echo "$tabs" | jq -r --arg id "$current_tab" \
    '.result.tabs | to_entries | .[] | select(.value.tab_id == $id) | .key')

  if [ -z "$cur_idx" ]; then
    echo "error: current tab '$current_tab' not found in tab.list for workspace '$current_ws'" >&2
    exit 1
  fi

  move=$(compute_move "$direction" "$cur_idx" "$len") || exit 0
  read -r insert_idx final_idx _ _ <<<"$move"

  echo "moving tab '$current_tab' from index $cur_idx $direction to $final_idx (insert_index=$insert_idx)"
  echo "{\"id\":\"req_move\",\"method\":\"tab.move\",\"params\":{\"tab_id\":\"$current_tab\",\"insert_index\":$insert_idx}}" \
    | nc -U "$SOCK" | jq '.result.tabs | to_entries | map({i:.key, id:.value.tab_id, label:.value.label})'
fi
