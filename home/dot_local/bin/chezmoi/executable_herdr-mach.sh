#!/bin/bash

fail() {
  echo "$@" >&2
  exit 1
}

usage() {
  echo "$0 enable|disable [machine1 machine2 ...]"
}

operation="$1"
shift
labels="$@"

function enable() {
  [ "$@" ] && usage
  labels="$(herdr machine list --json | jq -r '.[] | select(.enabled == false) | .id')" ||
    fail "could not get machine list"
  [ "${labels}" ] || fail "no machines disabled!"
  for label in ${labels}; do
    herdr machine enable ${label} || fail "could not enable machine ${label}"
  done
}

function disable() {
  [ "$@" ] || usage
  for label in "${@}"; do
    id="$(herdr machine list --json | jq -r '.[] | select(.label == "'${label}'") | .id')" ||
      fail "could not get machine id for ${label}"
    [ "${id}" ] || fail "no machine with label ${label}"
    herdr machine disable ${id} || fail "could not disable machine with label ${label}"
  done
}

case "$operation" in
enable) enable "$@" ;;
disable) disable "$@" ;;
*) usage ;;
esac
