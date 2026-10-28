#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT"
PACKAGE_TOOL=${PACKAGE_TOOL:-/mnt/HaikuWork/x399/build/x86_64/objects/linux/x86_64/release/tools/package/package}
BASETAG=$(git tag -l 'v*' --sort=-v:refname | head -1)
[ -z "$BASETAG" ] && BASETAG=v0.0.0
AHEAD=$(git rev-list --count "$BASETAG"..HEAD 2>/dev/null || echo 0)
VERSION=$(echo "$BASETAG" | sed 's/^v//')~git.$AHEAD.$(git rev-parse --short HEAD)
STAGE=$(mktemp -d /tmp/buildx-pkg-XXXXXX)
trap 'rm -rf -- "$STAGE"' EXIT
mkdir -p "$ROOT/artifacts" "$STAGE/lib/docker/cli-plugins" \
    "$STAGE/documentation/packages/docker_buildx"
for arch in "${@:-amd64 arm64}"; do
    haiku_arch=$arch
    [ "$arch" = "amd64" ] && haiku_arch=x86_64
    bin="build/haiku-$arch/docker-buildx"
    [ -f "$bin" ] || { echo ">> building $arch first"; bash tools-build-haiku.sh "$arch"; }
    rm -rf "$STAGE/lib/docker/cli-plugins/docker-buildx" "$STAGE/.PackageInfo"
    cp "$bin" "$STAGE/lib/docker/cli-plugins/docker-buildx"
    cat > "$STAGE/.PackageInfo" <<INFOEOF
name docker_buildx
version $VERSION-1
architecture $haiku_arch
summary "Docker Buildx for air/OS"
description "The docker buildx plugin for air/OS, ported from the open-source buildx. The plugin runs and reports version; full BuildKit solves need deeper snapshot plumbing on Haiku (the legacy 'docker build' builder works today)."
packager "air/OS contributors"
vendor "air/OS"
copyrights { "2026 air/OS contributors" "Docker, Inc." }
licenses { "Apache v2" }
provides {
    docker_buildx = $VERSION
    cmd:docker_buildx = $VERSION
}
requires {
    haiku >= r1~beta5
    docker_cli
}
INFOEOF
    out="$ROOT/artifacts/docker_buildx-$VERSION-1-${haiku_arch}.hpkg"
    "$PACKAGE_TOOL" create -C "$STAGE" "$out"
    echo ">> $out"
done
