# Get operating system
FROM ubuntu:22.04

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update  --fix-missing -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y clang make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev lzma python3-openssl
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y bc wget git perl parallel r-base imagemagick
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y vim # in case one would need to modify/adapt any script

# Copy repository
COPY . /qsmells-artifact

# Run `get-tools.sh` script to configure and install all required apps, packages, ..., clone any required repository, etc.
RUN /qsmells-artifact/tools/get-tools.sh

# EOF

# Useful docker-related commands
#
# YOUR_DOCKER_HUB_USERNAME=...
#
# 0. Prune docker from any existing image or container
# docker rm --volumes --force $(docker ps --all --quiet)
# docker rmi --force $(docker images --all --quiet)
# docker system prune
#
# 1. Build the container (< 20 minutes)
# docker build -t qsmells-artifact .
# 2. Tag your image before pushing
# docker tag qsmells-artifact "$YOUR_DOCKER_HUB_USERNAME/qsmells-artifact"
# 3. Login to the docker
# docker login
# 4. Push the container to https://hub.docker.com (< 3 minutes)
# docker push "$YOUR_DOCKER_HUB_USERNAME/qsmells-artifact"
#
# Then, and on another machine:
# 5. Pull the container from https://hub.docker.com (< 1 minute)
# docker pull "$YOUR_DOCKER_HUB_USERNAME/qsmells-artifact"
# 6. Connect to the container
# docker run --interactive --tty --privileged --workdir /qsmells-artifact/ "$YOUR_DOCKER_HUB_USERNAME/qsmells-artifact"
# 7. Run any command of each experiment/analysis
