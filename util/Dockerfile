FROM ubuntu:24.04

ARG USERNAME

ENV TZ=America/Los_Angeles
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata \
 && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y
RUN apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractiveyy apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  gpg \
  sudo \
  zsh

RUN install -dm 755 /etc/apt/keyrings
RUN curl -fSs https://mise.en.dev/gpg-key.pub >> /etc/apt/keyrings/mise-archive-keyring.asc
RUN echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.en.dev/deb stable main" >> /etc/apt/sources.list.d/mise.list

RUN apt-get update -y

RUN DEBIAN_FRONTEND=noninteractiveyy apt-get install -y --no-install-recommends \
  mise

RUN useradd -m -s /usr/bin/zsh -d /home/${USERNAME} ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} . /home/${USERNAME}/.local/share/chezmoi

WORKDIR /home/${USERNAME}/
USER ${USERNAME}

RUN echo 'source <(mise activate bash)' >> /home/${USERNAME}/.bashrc
RUN mise use -g chezmoi
RUN mise use -g jq
RUN mise use -g jsonschema
RUN mise exec chezmoi -- chezmoi init -v
RUN mise exec chezmoi -- chezmoi apply -v
RUN mise install
RUN mise run -s 'zsh -c' post-install
