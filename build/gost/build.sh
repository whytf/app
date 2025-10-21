#!/bin/bash

# Build script for EarnApp with GOST Proxy Docker image
# Usage: ./build.sh [tag]

set -e

# Configuration
IMAGE_NAME="killermantv/gostprod"
DEFAULT_TAG="latest"
TAG="${1:-$DEFAULT_TAG}"
FULL_IMAGE="${IMAGE_NAME}:${TAG}"

echo "====================================="
echo "Building EarnApp with GOST Proxy"
echo "====================================="
echo "Image: ${FULL_IMAGE}"
echo "Build context: $(pwd)"
echo "====================================="

# Build the image
echo "Building Docker image..."
docker build -t "${FULL_IMAGE}" .

echo ""
echo "====================================="
echo "Build completed successfully!"
echo "====================================="
echo "Image: ${FULL_IMAGE}"
echo ""
echo "Next steps:"
echo "  1. Test the image locally:"
echo "     docker run --rm -it --privileged \\"
echo "       -e ADDR=192.168.1.100:1080 \\"
echo "       -e USERNAME=myuser \\"
echo "       -e PASSWORD=mypass \\"
echo "       -e UUID=sdk-node-test123 \\"
echo "       -e HOSTNAME=test-node \\"
echo "       ${FULL_IMAGE}"
echo ""
echo "  2. Push to Docker Hub:"
echo "     docker push ${FULL_IMAGE}"
echo ""
echo "  3. Deploy using docker-compose:"
echo "     cd ../.. && ./generate-compose.sh containers.txt > docker-compose.yml"
echo "     docker-compose up -d"
echo "====================================="
