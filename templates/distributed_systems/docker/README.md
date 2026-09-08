# Docker

This example code covers development and usage with heavy comments to
understand functionality and best practice as of 20260428.
https://mpolinowski.github.io/docs/DevOps/Linux/2019-09-25--podman-cheat-sheet/2019-09-25/

More performance oriented alternative to docker/podman and docker-compose is
[apptainer](https://apptainer.org/docs/user/1.0/docker_and_oci.html), which
recommends process compose with yaml files as config and has no OCI runtime overhead
unless configured as such.
Other alternatives are depend on use cases. See cri, oci, both (cri-o) compliance
for Kubernetes compatibility (oci).

General container properties apply, see ./templates/distributed_systems/container.txt

## Structure

```
templates/distributed_systems/docker/
* .dockerignore
* Dockerfile
```

## Best Practice

https://oneuptime.com/blog/post/2026-03-18-write-efficient-containerfile-podman/view
* Filesystem-changing instructions in a Containerfile, such as COPY, ADD, and
  RUN, create layers in the resulting image
* Order instructions for cache efficiency
* Minimize number of layers by combining commands into single RUN instruction

1. Use Multi-stage Builds
Multi-stage builds allow you to use multiple FROM statements in your
Dockerfile. This is useful for creating smaller production images by separating
build-time dependencies from runtime dependencies.

```Containerfile
FROM docker.io/library/node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM docker.io/library/node:22-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
CMD ["node", "dist/index.js"]
```

2. Minimize Layer Count and Size
* Group related commands in a single RUN instruction to reduce layers
* Clean up package manager caches in the same RUN instruction
* Use .dockerignore to exclude unnecessary files
* Choose smaller base images (e.g., alpine variants)

3. Security Best Practices
* Avoid running containers as root by using the USER instruction
* Set proper file permissions
* Never store secrets in the Dockerfile (use environment variables or secrets management)
* Scan images for vulnerabilities
* Use specific version tags instead of 'latest'

4. Additional Recommendations
* Use COPY instead of ADD for simple file copying
* Set WORKDIR instead of using RUN cd
* Use ENTRYPOINT with CMD for better container execution
* Include HEALTHCHECK instructions to monitor container health
* Sort multi-line arguments alphanumerically to avoid duplication

## Usage

```
docker build -f templates/distributed_systems/docker/Dockerfile
docker container start
see https://docs.docker.com/reference/cli/docker/
```

## How does it work?

idea better explanation of build system
