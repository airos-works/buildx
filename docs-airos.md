# docker-buildx for air/OS

air/OS port of Docker Buildx (airos-works fork of docker/buildx).

## Status

- Builds for haiku/amd64 + haiku/arm64 (`tools-build-haiku.sh`), packages
  as `docker_buildx` with the CLI plugin at
  `lib/docker/cli-plugins/docker-buildx` (`tools-package-haiku.sh`).
- The plugin runs: `docker buildx version` works.
- Full BuildKit solves are not enabled yet: the in-daemon BuildKit snapshot
  path still hits unimplemented pieces on Haiku (bind-mount emulation in the
  local source reader). The legacy `docker build` builder works on air/OS
  today, including RUN steps.
