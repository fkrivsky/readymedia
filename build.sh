#!/bin/bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx build --push --platform linux/arm/v7,linux/arm64,linux/amd64 --tag fkrivsky/readymedia:$(date +"%Y-%m-%d") --tag fkrivsky/readymedia:latest .