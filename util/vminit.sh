#!/bin/bash
set -ex


HOME="${HOME:-~}"
REPO="https://github.com/mikecurtis/dotfiles"
BREWUSER="brewdog"

fail () {
  echo "$@" >&2
  exit 1
}

if [ "$1" ]; then
  INITUSER="$1"
fi
[ "${INITUSER}" ] || fail "No user specified!"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "${ID}" in
  amzn)
    OS="fedora"
    ;;
  arch | archarm)
    OS="arch"
    ;;
  ubuntu)
    OS="ubuntu"
    ;;
  esac
fi

if [ -z "$OS" ]; then
  fail "Unknown OS"
fi

confirm () {
  ${YES} && return
  read -p "$@ " choice
  case "$choice" in
  y | Y) return 0 ;;
  n | N) return 1 ;;
  *) confirm "$@" ;;
  esac
}

force () {
  ${FORCE} && return
  read -p "$@ " choice
  case "$choice" in
  y | Y) return 0 ;;
  n | N) return 1 ;;
  *) force "$@" ;;
  esac
}

check_which () {
  which $1 >/dev/null 2>&1
  return $?
}

install () {
  case "${OS}" in
  arch)
    pacman --noconfirm --needed -Suy $* ||
      fail "${installer} install failed"
    ;;
  fedora)
    dnf update -y &&
      dnf install -y $* ||
      fail "dnf install failed"
    ;;
  ubuntu)
    apt update -y &&
      apt install -y $* ||
      fail "apt install failed"
    ;;
  *)
    fail "Unknown installation!"
    ;;
  esac
}

check_install () {
  if ! check_which $1; then
    if confirm "No $1 found.  Install?"; then
      install $1 || fail "$1 installation failed!"
    else
      fail "User aborted"
    fi
  fi
  check_which $1 || fail "No $1 found!"
}

install_base_packages () {
  if [ "${OS}" = "arch" ]; then
    install base-devel
    check_install sudo
  fi
}

create_inituser () {
  if ! id ${INITUSER} >/dev/null 2>&1; then
    useradd -m -U ${INITUSER}
  fi
  if ! [ -f /etc/sudoers.d/${INITUSER} ]; then
    echo "${INITUSER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${INITUSER}
  fi
}

install_base_packages
create_inituser
