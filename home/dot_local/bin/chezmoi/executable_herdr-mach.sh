#!/bin/bash

fail() {
  echo "$@" >&2
  exit 1
}

usage() {
  echo "$0 enable|disable [machine1 machine2 ...]"
  exit 1
}

operation="$1"
shift
labels="$@"

function flip() {
  enabled=$1
  shift
  action=$1
  shift
  labels="$@"
  [ "${labels}" ] || labels="$(herdr machine list --json | jq -r '.[] | select(.enabled == '${enabled}') | .label')"
  for label in "${labels}"; do
    id="$(herdr machine list --json | jq -r '.[] | select(.label == "'${label}'") | .id')" ||
      fail "could not get machine id for ${label}"
    [ "${id}" ] || fail "no machine with label ${label}"
    herdr machine ${action} ${id} || fail "could not disable machine with label ${label}"
  done
}

function enable() {
  flip false enable "$@"
}

function disable() {
  flip true disable "$@"
}

case "$operation" in
enable) enable "$@" ;;
disable) disable "$@" ;;
*) usage ;;
esac
