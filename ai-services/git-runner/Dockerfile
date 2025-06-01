FROM ubuntu:25.10

ARG RUNNER_VERSION="2.324.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev libicu-dev python3 python3-venv python3-dev python3-pip unzip docker.io


WORKDIR /home/docker

RUN mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && echo "e8e24a3477da17040b4d6fa6d34c6ecb9a2879e800aa532518ec21e49e21d7b4  actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh


COPY scripts/start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# https://docs.astral.sh/uv/guides/integration/docker/#installing-uv   
# ADD https://astral.sh/uv/0.7.8/install.sh /home/docker/uv-installer.sh
# RUN chmod +x /home/docker/uv-installer.sh
# RUN sh /home/docker/uv-installer.sh | env UV_INSTALL_DIR="/home/docker" && rm /home/docker/uv-installer.sh

# # Ensure the installed binary is on the `PATH`
# ENV PATH="/home/docker/:$PATH"

#RUN uv --RUNNER_VERSION

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]