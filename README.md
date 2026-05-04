# BlueZ 5.82 Backport for Debian Bookworm

This repository builds BlueZ 5.82 (from Debian Trixie) as a backport for Debian Bookworm (12).

## How it works

The build runs entirely inside a Docker container based on `debian:bookworm`. The Dockerfile:

1. Sets up a bookworm build environment with `devscripts`, `dpkg-dev`, and `build-essential`.
2. Downloads the official BlueZ 5.82-1.1 source package directly from the Debian Trixie archive (`.orig.tar.gz`, `.debian.tar.xz`, and `.dsc`).
3. Extracts the source package using `dpkg-source`, which applies all Trixie patches automatically.
4. Patches `debian/control` for bookworm compatibility (`systemd-dev` does not exist in bookworm, so it is replaced with `systemd`).
5. Adds a `~bpo12+1` version suffix via `dch` to mark it as a backport.
6. Installs all build dependencies and builds the binary packages with `dpkg-buildpackage`.
7. Collects the resulting `.deb` files in `/output/`.

## Releases

A GitHub Actions workflow automatically builds `arm64` packages on every tag push. The `.deb` files are published as assets on the corresponding GitHub release.

To create a release:

```bash
git tag v5.82-1
git push origin v5.82-1
```

Pre-built packages can be downloaded from the [Releases](../../releases) page.

## Local build

To build locally using Docker:

```bash
docker build -t bluez-backport .
docker create --name bluez-build bluez-backport
docker cp bluez-build:/output/ ./output
docker rm bluez-build
```

The `.deb` files will be in `./output/`. The build produces packages for the architecture of the Docker host (e.g., `arm64` on Apple Silicon / Raspberry Pi, `amd64` on x86_64).

## Installing on Bookworm

Copy the `.deb` files to your bookworm target and install:

```bash
sudo dpkg -i bluez_5.82-*.deb libbluetooth3_5.82-*.deb
sudo apt-get install -f
```
