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
  --rebuild
      Rebuild image and start fresh
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
    --rebuild)
      _REBUILD=true
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
IMAGE_NAME="dotfiles-test-${_DISTRO}"
CONTAINER_NAME="dotfiles-test-container-${_DISTRO}"


# Build the image if needed
if ${_REBUILD} || ! docker image inspect "${IMAGE_NAME}" &>/dev/null; then
    echo "Building Docker image..."
    docker build --file img-${_DISTRO}.Dockerfile -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
    _RESET=true  # rebuild implies reset
fi

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
    #docker exec -it "${CONTAINER_NAME}" tmux attach -t main 2>/dev/null \
    #    || docker exec -it "${CONTAINER_NAME}" tmux new -s main
    exit 0
fi

# Create and start new container
echo "Starting fresh Linux environment..."
echo ""

docker run -d --name "${CONTAINER_NAME}" "${IMAGE_NAME}" sleep infinity

TMPDIR="/tmp/bootstrap"
set -ex

# TODO: adjust for different distro
docker exec -i -u root -t "${CONTAINER_NAME}" bash -c "apt update -y && apt install -y curl gpg sudo"
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
      # docker cp ${f} exec -i -u root -t "${CONTAINER_NAME}" curl -fsSL ${REMOTE_UTIL}/${script} -o ${TMPDIR}/util/${script}
      docker exec -i -u root -t "${CONTAINER_NAME}" chmod 755 ${TMPDIR}/util/${script}
    done

fi

# Run root setup.
docker exec -i -u root -t "${CONTAINER_NAME}" ${TMPDIR}/util/vminit.sh ${_USER}
docker exec -i -u ${_USER} -t "${CONTAINER_NAME}" ${TMPDIR}/util/bootstrap.sh
docker exec -i -u ${_USER} -t "${CONTAINER_NAME}" zsh
