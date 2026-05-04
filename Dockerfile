# Build BlueZ 5.82 (from Trixie) for Bookworm
FROM debian:bookworm

# Add source repos
RUN echo "deb-src http://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        devscripts dpkg-dev wget ca-certificates \
        build-essential fakeroot

WORKDIR /buildroot

# Download BlueZ 5.82 Trixie source package (source + debian packaging + patches)
RUN wget http://deb.debian.org/debian/pool/main/b/bluez/bluez_5.82.orig.tar.gz && \
    wget http://deb.debian.org/debian/pool/main/b/bluez/bluez_5.82-1.1.debian.tar.xz && \
    wget http://deb.debian.org/debian/pool/main/b/bluez/bluez_5.82-1.1.dsc

# Extract source package
RUN dpkg-source -x bluez_5.82-1.1.dsc

WORKDIR /buildroot/bluez-5.82

# Bookworm compatibility: systemd-dev does not exist in bookworm
RUN sed -i 's/systemd-dev/systemd/' debian/control

# Remove lsb-base dependency (not required by bluez 5.82, was leftover in old packaging)
# Add backport version to changelog
RUN DEBEMAIL="backport@local" DEBFULLNAME="Backport" \
    dch --local ~bpo12+ --distribution bookworm-backports "Backport to bookworm."

# Install build dependencies
RUN apt-get install -y --no-install-recommends \
        debhelper \
        flex bison libdbus-1-dev libglib2.0-dev libdw-dev libudev-dev \
        libreadline-dev libical-dev libasound2-dev libjson-c-dev \
        libell-dev python3-docutils python3-pygments udev check systemd \
        libebook1.2-dev

# Build the package
RUN dpkg-buildpackage -us -uc -b

# Collect output debs
WORKDIR /buildroot
RUN mkdir -p /output && cp *.deb /output/ 2>/dev/null || true
