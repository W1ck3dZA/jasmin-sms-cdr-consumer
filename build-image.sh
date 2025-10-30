#!/bin/bash

# Build script for Jasmin Broker Docker image
# Usage: ./build-image.sh [IMAGE_NAME] [TAG]

set -e

# Default values
IMAGE_NAME="${1:-jasmin-sms-cdr-consumer}"
TAG="${2:-latest}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo "=========================================="
echo "Building Docker Image"
echo "=========================================="
echo "Image Name: ${FULL_IMAGE_NAME}"
echo "=========================================="

# Build the Docker image
docker build -f config/Dockerfile -t "${FULL_IMAGE_NAME}" .

echo "=========================================="
echo "Build completed successfully!"
echo "Image: ${FULL_IMAGE_NAME}"
echo "=========================================="

# Display image info
docker images "${IMAGE_NAME}" --filter "reference=${FULL_IMAGE_NAME}"

echo ""
echo "To run the image:"
echo "  docker run -d --name jasmin-broker ${FULL_IMAGE_NAME}"
echo ""
echo "To push the image:"
echo "  ./push-image.sh ${IMAGE_NAME} ${TAG}"
