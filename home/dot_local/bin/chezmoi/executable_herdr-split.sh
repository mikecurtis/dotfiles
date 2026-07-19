#!/bin/bash

ERROR_LOG="/tmp/split.err"
DIRECTION=

function fail() {
  echo "$@" >>${ERROR_LOG}
  exit 1
}

case "$1" in
-h)
  DIRECTION=right
  ;;
-v)
  DIRECTION=down
  ;;
*)
  fail "Must specify -h or -v"
  ;;
esac

SWITCH_HOST="$(herdr pane process-info |
  jq -r '.result.process_info.foreground_processes[] | select(.argv0 == "devbox").argv[] | select(. | startswith("devbox_"))')"

echo "${SWITCH_HOST}" >/tmp/h

exec herdr pane split --focus \
  --direction ${DIRECTION} \
  --env SWITCH_HOST=${SWITCH_HOST} \
  --env SWITCH_USER=${SWITCH_USER} ||
  fail "Could not exec!"
