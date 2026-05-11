# Docker

This example code covers development and usage with heavy comments to
understand functionality and best practice as of 20260428.

## Requirements

1. docker or podman
2. Dockerfile linter
3. compose linter, yaml linter
4. TODO build analyzer?
5. TODO image analyzer? ie secrets etc

## Structure

```
templates/distributed_systems/docker/
* .dockerignore
* Dockerfile
* TODO https://github.com/spryker/docker-sdk/blob/master/.dockerignore.default
  what does the following mean
  !/docker/deployment/
  !/data/import
/tests/*/*/*/_output/*
.docker-sync
/docker
!/docker/deployment/
!/src/Orm/Propel/.gitkeep
```

## Usage

```
docker build -f templates/distributed_systems/docker/Dockerfile
docker TODO start
```

## How does it work?

### docker build context
https://docs.docker.com/compose/gettingstarted/
https://codefresh.io/blog/not-ignore-dockerignore-2/

.dockerignore
- https://docs.docker.com/reference/dockerfile#dockerignore-file
- reduce docker image size (filetree starting at Dockerfile used)
- unintended secrets exposure
- docker build -- cache invalidation through common pattern COPY . /usr/src/app
```.dockerignore
pattern:
{ term }
term:
'*' matches any sequence of non-Separator characters
'?' matches any single non-Separator character
'[' [ '^' ] { character_range } ']'
character class (must be non-empty)
c matches character c (c != '*', '?', '\', '[')
'\' c matches character c
character_range:
c matches character c (c != '\', '-', ']')
'\' c matches character c
lo '-' hi matches character c for lo <= c <= hi
additions:
'**' matches any number of directories (including zero)
'!' lines starting with ! (exclamation mark) can be used to make exceptions to exclusions
'#' comments (lines when starting with # are ignored)
TODO fixup additions
```
TODO check if better .dockerignore syntax description exists

Dockerfile
- https://docs.docker.com/reference/dockerfile/
- TODO

TODO debug docker build artifacts
- https://docs.docker.com/reference/build-checks/
- lsp etc?

### docker runtime context

TODO list different runtime options for docker

.docker-compose ??
- https://docs.docker.com/reference/compose-file/
- https://docs.docker.com/compose/intro/compose-application-model/
