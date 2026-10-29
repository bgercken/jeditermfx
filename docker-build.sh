#!/usr/bin/env bash
#
#
podman run --rm \
    -v "$PWD":/workspace:Z \
    -v jeditermfx-m2:/root/.m2 \
    -w /workspace \
    docker.io/library/maven:3.9-eclipse-temurin-17 \
    mvn -B clean install


