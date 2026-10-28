#!/usr/bin/env bash
# Cross-build docker-buildx for air/OS (Haiku) from Linux.
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT"
TOOLCHAIN=${GO_HAIKU_TOOLCHAIN:-/mnt/HaikuWork/toolchains/go-haiku}
for arch in "${@:-amd64 arm64}"; do
    out="build/haiku-$arch/docker-buildx"
    mkdir -p "$(dirname "$out")"
    echo ">> building haiku/$arch -> $out"
    GOOS=haiku GOARCH="$arch" CGO_ENABLED=0 GOFLAGS=-mod=vendor \
        "$TOOLCHAIN/bin/go" build -trimpath -ldflags="-s -w" -o "$out" ./cmd/buildx
done
