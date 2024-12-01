## Contents

- `Dockerfile`: The Dockerfile used to build the image.
- `build.sh`: The script to build and push the Docker image.

## Prerequisites

- Docker installed on your machine.
- Docker Buildx plugin (included with Docker Desktop).

## Building the Docker Image

To build the Docker image for the `linux/amd64` platform, run the following command:

```sh
cd docker
./build.sh
```
This script will create a new builder instance and build the image for the linux/amd64 platform.

## Running the Image

To run the Docker image, use the following command:

```sh
docker run -it hatmatrix/uros2024:latest
```

This will start a container and launch radian.

## Usage on Windows

Windows users can run this Docker image using Docker Desktop with WSL 2 enabled. Follow these steps:

1. Install Docker Desktop from Docker's official website.
1. Ensure WSL 2 is enabled.
2. Pull and run the Docker image using the following commands: