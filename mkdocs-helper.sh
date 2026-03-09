#!/bin/bash

set -e

which docker &> /dev/null || { echo "Docker must be installed (and in your PATH) to use this build script. Exiting."; exit 1; }

IMAGE_NAME="sceptre-phenix-docs-builder"
USER_UID=$(id -u)
USER_GID=$(id -g)

# Build the image only if it doesn't exist
if [[ "$(docker images -q ${IMAGE_NAME} 2> /dev/null)" == "" ]]; then
  echo "Building documentation builder image: ${IMAGE_NAME}"
  # Use a heredoc to pass the Dockerfile to docker build
  docker build -t ${IMAGE_NAME} -f - . <<EOF
FROM squidfunk/mkdocs-material

# Install mike for versioning and other dependencies from mkdocs.yml
COPY requirements.txt .
RUN pip install -r requirements.txt

# Clear the entrypoint so we can choose between 'mkdocs' and 'mike'
ENTRYPOINT []
EOF
fi

# If no arguments are provided, default to standard mkdocs serve (for dev/hot-reload).
# Otherwise, use mike (for versioning/deploy tasks).
if [ "$#" -eq 0 ]; then
  # Use mkdocs for live development
  ARGS=("mkdocs" "serve" "-a" "0.0.0.0:8000")
else
  # Use mike for specific commands (e.g., deploy, list)
  ARGS=("mike" "$@")
fi

echo "Running command: ${ARGS[*]}"
docker run -it --rm -p 8000:8000 -v "${PWD}:/docs" -w /docs -u "${USER_UID}:${USER_GID}" "${IMAGE_NAME}" "${ARGS[@]}"
