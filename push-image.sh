#!/bin/bash

# Push script for Jasmin Broker Docker image
# Usage: ./push-image.sh [IMAGE_NAME] [TAG] [REGISTRY]

set -e

# Default values
IMAGE_NAME="${1:-jasmin-sms-cdr-consumer}"
TAG="${2:-latest}"
REGISTRY="${3:-docker.io}"

# Construct the full image name
if [ -n "${REGISTRY}" ]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"
    LOCAL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"
else
    FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"
    LOCAL_IMAGE_NAME="${FULL_IMAGE_NAME}"
fi

echo "=========================================="
echo "Pushing Docker Image"
echo "=========================================="
echo "Local Image: ${LOCAL_IMAGE_NAME}"
echo "Target: ${FULL_IMAGE_NAME}"
echo "=========================================="

# Tag the image if registry is specified
if [ -n "${REGISTRY}" ]; then
    echo "Tagging image for registry..."
    docker tag "${LOCAL_IMAGE_NAME}" "${FULL_IMAGE_NAME}"
fi

# Push the image
echo "Pushing image to registry..."
docker push "${FULL_IMAGE_NAME}"

echo "=========================================="
echo "Push completed successfully!"
echo "Image: ${FULL_IMAGE_NAME}"
echo "=========================================="

echo ""
echo "To pull the image:"
echo "  docker pull ${FULL_IMAGE_NAME}"
