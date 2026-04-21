#!/usr/bin/env bash
set -euo pipefail

VM_NAME="${VM_NAME:-k3s-master}"
IMAGE_NAME="${IMAGE_NAME:-atelier-kubernetes}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"
ARCHIVE_PATH="/tmp/${IMAGE_NAME//\//_}-${IMAGE_TAG}.tar"

if ! command -v multipass >/dev/null 2>&1; then
  echo "multipass is required"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required"
  exit 1
fi

echo "Saving ${IMAGE_NAME}:${IMAGE_TAG} to ${ARCHIVE_PATH}"
docker save -o "$ARCHIVE_PATH" "${IMAGE_NAME}:${IMAGE_TAG}"

echo "Transferring image archive to ${VM_NAME}"
multipass transfer "$ARCHIVE_PATH" "${VM_NAME}:/tmp/image.tar"

echo "Importing image in k3s containerd"
multipass exec "$VM_NAME" -- sudo k3s ctr images import /tmp/image.tar

echo "Listing imported image"
multipass exec "$VM_NAME" -- sudo k3s ctr images ls | grep "$IMAGE_NAME" || true

echo "Done"

