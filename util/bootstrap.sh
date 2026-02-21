#!/bin/bash

set -ex

HOME="${HOME:-~}"
REPO="https://github.com/mikecurtis/dotfiles"
BREWUSER="brewdog"

fail () {
  echo "$@" >&2
  exit 1
}

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
  if type uname >/dev/null 2>&1; then
    case "$(uname)" in
    Darwin)
      OS="macos"
      ;;
    esac
  fi
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
    sudo pacman --noconfirm --needed -Suy $* ||
      fail "${installer} install failed"
    ;;
  fedora)
    sudo dnf update -y &&
      sudo dnf install -y $* ||
      fail "dnf install failed"
    ;;
  ubuntu)
    sudo apt update -y &&
      sudo apt install -y $* ||
      fail "apt install failed"
    ;;
  macos)
    if [ "${BREWUSER}" ]; then
      sudo -i -u ${BREWUSER} sh -c "brew update && brew install $*" ||
        fail "brew install failed"
    else
      brew update &&
        brew install $* ||
        fail "brew install failed"
    fi
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

check_install_mise () {
  if ! check_which mise; then
    case "${OS}" in
    ubuntu)
      sudo install -dm 755 /etc/apt/keyrings
      curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg
      echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
      check_install mise
      ;;
    macos)
      check_install mise
      ;;
    *)
      curl https://mise.run | sh
      check_which mise || fail "No mise found!"
      ;;
    esac
  fi
}

chsh_zsh () {
  shell=""
  if [ "${OS}" = "macos" ]; then
    shell="$(dscl . -read /Users/${USER} UserShell | awk '{print $2}' | awk -F/ '{print $NF}')"
  else
    shell="$(grep "^${USER}:" /etc/passwd | cut -d: -f7 | awk -F/ '{print $NF}')"
  fi
  if [ "${shell}" != "zsh" ]; then
    bin="$(grep zsh /etc/shells | head -1)"
    [ "${bin}" ] || die "Could not find zsh in /etc/shells"
    # chsh not installed by default.
    if [ "${OS}" = "fedora" ]; then
      install util-linux-user
    fi
    if sudo true 2>/dev/null; then
      sudo chsh -s ${bin} ${USER} || fail "Failed to sudo chsh"
    else
      chsh -s ${bin} || fail "Failed to chsh"
    fi
  fi
  local rcFile="${HOME}/.zshrc"
  if ! [ -f "${rcFile}" ]; then
    cat > "${rcFile}" <<EOF
source "${HOME}/.config/zsh/zshrc"
EOF
  fi
}

bootstrap_chezmoi () {

  mise use -g chezmoi || fail "chezmoi install failed"
  # used for validating chezmoi data
  mise use -g jq
  mise use -g jsonschema

  local brewUserLine=
  local brewsLine=
  if [ "${OS}" = "macos" ]; then
    brewUserLine="brewuser = \"${BREWUSER}\""
    brewsLine="$(cat <<EOF
brew.brews = []
brew.casks = []
EOF)"
  fi

  userLocalDir="${HOME}/.config/chezmoi/"
  userLocalData="${userLocalDir}/chezmoi.userlocal.toml"
  if ! [ -f "${userLocalData}" ]; then
    mkdir -p "${userLocalDir}"
    cat > "${userLocalData}" <<EOF
[data.chezmoidata.userlocal]
gituser = "${USER}"
${brewUserLine}
EOF
  fi

  machLocalDir="/var/lib/chezmoi"
  machLocalData="${machLocalDir}/chezmoi.machlocal.toml"
  local brewline=
  if ! [ -f "${machLocalData}" ]; then
    sudo mkdir -p "${machLocalDir}"
    sudo chmod 755 "${machLocalDir}"
    sudo touch "${machLocalData}"
    sudo chmod 666 "${machLocalData}"
    sudo cat > "${machLocalData}" <<EOF
[data.chezmoidata.machlocal]
compaudit.allow = []
${brewsLine}
EOF
    sudo chmod 644 "${machLocalData}"
  fi

  mise exec chezmoi -- chezmoi init -v ${REPO} || fail "could not init chezmoi"
  mise exec chezmoi -- chezmoi apply -v || fail "could not apply chezmoi"
  mise install
}

[ "${OS}" = "arch" ] && install base-devel
check_install curl
check_install git
check_install zsh
check_install_mise
chsh_zsh
bootstrap_chezmoi
