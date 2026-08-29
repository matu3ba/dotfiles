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

## Dependencies
- Unix environment (ie WSL, docker desktop has problems)
- containers: (podman or docker) xor apptainer xor OCI container
  * all of these are for application virtualization
  * OS virtualization are different and incompatible (qemu, lxc, OpenVZ, kvm, xen, etc)
- docker-compose (podman-compose may get stuck and has problems),
  * alternative (ie for apptainer): process-compose

## Development recommendations

Containerfile
1. docker or podman
2. Containerfile linter
   * hadolint
   * docker
```
# syntax=docker/dockerfile:1
# check=error=true
# check=skip=JSONArgsRecommended,StageNameCasing
docker build --check --build-arg "BUILDKIT_DOCKERFILE_CHECK=skip=JSONArgsRecommended,StageNameCasing" .
```
   * https://docs.docker.com/reference/build-checks/
   * podman https://developers.redhat.com/articles/2025/02/26/best-practices-building-bootable-containers
```
bootc container lint
```
     - cli simplification https://willhbr.net/2026/03/13/language-servers-in-containers/
3. lsp: https://github.com/docker/docker-language-server
3. build analyzer: `docker build --check .`, podman has nothing
4. image analyzer (for security etc): unconclusive by criteria, there are many options without clear winner
5. explore each layer in a docker image: https://github.com/wagoodman/dive
6. All-in-one security analyzer https://github.com/aquasecurity/trivy

Compose.yml
1. docker-compose
   * podman compose misses features
     - Red-Hat pushes quadlets instead of docker-compose compatibility
   * alternative often used with apptainer: process-compose.yml
     - ./process-compose -f process-compose.yml
   * alternative for using with systemd quadlet https://github.com/onlyati/quadlet-lsp
2. compose linter
   * compose-lint (https://pypi.org/project/compose-lint/) for security
     - simple and has great "How it compares"
     - no json support
   * dclint (typescript-based) option for only schema/structure
     - no json support
3. yaml linter: https://github.com/adrienverge/yamllint
   * yaml fmt: https://xkyle.com/A-Detailed-Comparison-of-YAML-Formatters/
   * yaml validate: https://www.liquidweb.com/blog/validate-yaml/

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
