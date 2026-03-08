#!/bin/bash
# Test dotfiles in an isolated Linux environment

SCRIPT_DIR="$(dirname "$0")"
cd "${SCRIPT_DIR}"
REPO_ROOT="$(cd .. && pwd)"
REMOTE_UTIL="https://raw.githubusercontent.com/mikecurtis/dotfiles/refs/heads/main/util"

_LOCAL=false
_REBUILD=false
_RESET=false
_DISTRO=""
_USER=norm
_IMAGE=""

function fail() {
  echo "$@" >&2
  exit 1
}

function usage() {
  echo "$@" >&2
  echo >&2
  help >&2
  exit 1
}

function help() {
  cat <<EOF
Usage: $0 [options]

Options:
  --local
      Copy local repo for testing uncommitted changes
  --reset
      Reset to pristine state (removes container)
  --distro|-d DISTRO
      Distro to test
EOF
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      _LOCAL=true
      shift
      ;;
    --reset)
      _RESET=true
      shift
      ;;
    --distro|-d)
      _DISTRO="$2"
      shift 2
      ;;
    --distro=*)
      _DISTRO="${1#*=}"
      shift
      ;;
    --)
      shift
      POSITIONAL+=("$@")
      break
      ;;
    -*)
      usage "unknown flag: $1"
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done


# Restore positional parameters
set -- "${POSITIONAL[@]}"

[ ${#POSITIONAL[@]} -gt 0 ] && usage "positional arguments set"

[ "${_DISTRO}" ] || usage "No --distro set"

IMAGE_NAME=""
case "${_DISTRO}" in
  ubuntu)
    IMAGE_NAME="ubuntu:24.04"
    ;;
  arch)
    IMAGE_NAME="archlinux/archlinux:base-devel"
    ;;
  *)
    fail "Unknown distro: ${_DISTRO}"
    ;;
esac
CONTAINER_NAME="dotfiles-test-container-${_DISTRO}"


# Handle reset
if ${_RESET}; then
    echo "Removing container..."
    docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true
fi

# Check if container is stopped
if docker ps -aq -f name="${CONTAINER_NAME}" -f status=exited | grep -q .; then
    echo "Starting stopped container..."
    docker start "${CONTAINER_NAME}"
fi

# Check if container exists and is running
if docker ps -q -f name="${CONTAINER_NAME}" | grep -q .; then
    echo "Attaching to existing container..."
    docker exec -i -u "${_USER}" -t "${CONTAINER_NAME}" "zsh"
    exit 0
fi

# Create and start new container
echo "Starting fresh Linux environment..."
echo ""

docker run -d --name "${CONTAINER_NAME}" "${IMAGE_NAME}" sleep infinity

TMPDIR="/tmp/bootstrap"
set -ex

docker exec -i -u root -t "${CONTAINER_NAME}" mkdir -p ${TMPDIR}

if ${_LOCAL}; then
    echo "Copying local repo into container..."
    tar -C "${REPO_ROOT}" --exclude='.git' --exclude='*.swp' -cf - . \
        | docker exec -i "${CONTAINER_NAME}" tar -C ${TMPDIR} -xf -
    # TODO: Give bootstrap the ability to use local config
else
    echo "Fetching initialization scripts..."
    docker exec -i -u root -t "${CONTAINER_NAME}" mkdir -p ${TMPDIR}/util
    f=$(mktemp)
    trap "rm -f ${f}" EXIT
    for script in vminit.sh bootstrap.sh; do
      curl -fsSL ${REMOTE_UTIL}/${script} -o ${f}
      docker cp ${f} "${CONTAINER_NAME}:${TMPDIR}/util/${script}"
      docker exec -i -u root -t "${CONTAINER_NAME}" chmod 755 ${TMPDIR}/util/${script}
    done

fi

# Run root setup.
docker exec -i -u root -t "${CONTAINER_NAME}" ${TMPDIR}/util/vminit.sh ${_USER}
docker exec -i -u ${_USER} -t "${CONTAINER_NAME}" ${TMPDIR}/util/bootstrap.sh
docker exec -i -u ${_USER} -t "${CONTAINER_NAME}" zsh
