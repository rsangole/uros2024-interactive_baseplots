IMAGE_NAME=hatmatrix/uros2024:latest

# Create and use a new builder instance
docker buildx create --use

# Build and push the image
docker buildx build --platform linux/amd64 -t $IMAGE_NAME --push .