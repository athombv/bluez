# Use a Debian-based image as the base image
FROM debian:bullseye

RUN echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list
# Install the required packages for building Debian packages and BlueZ
RUN apt-get update && \
    apt-get install -y dh-make devscripts dpkg-dev git-buildpackage wget

# Set up the build environment
WORKDIR /buildroot
# Download the BlueZ 5.66 source code
RUN wget http://deb.debian.org/debian/pool/main/b/bluez/bluez_5.66.orig.tar.xz
RUN mkdir build

COPY ./debian /buildroot/build/debian

# Install the build dependencies for the package
RUN apt-get install -y flex bison libdbus-1-dev libglib2.0-dev libdw-dev libudev-dev libreadline-dev libical-dev libasound2-dev libjson-c-dev python3-docutils udev check systemd
RUN apt-get build-dep -y bluez

RUN ls -al .
# RUN cd bluez-5.66 && ./bootstrap
RUN cd build && dpkg-buildpackage -v -us -uc -b

# Publish the Debian package to GHCR
ARG GITHUB_TOKEN
RUN echo "machine github.com login $GITHUB_TOKEN" > ~/.netrc && \
    echo "machine api.github.com login $GITHUB_TOKEN" >> ~/.netrc && \
    git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name" && \
    git remote add origin https://github.com/your-org/your-repo.git && \
    git push --set-upstream origin master && \
    ghcr.io/your-org/your-repo/debian/$(ls *.deb)
