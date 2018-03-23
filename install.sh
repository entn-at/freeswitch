#!/usr/bin/env bash
# TODO(langep):
#   - Setup running as freeswitch user instead of root
#   - Setup running as service
set -e # Abort on error

# Set paramaters
# TODO(langep): Make parameters configurable
download_location=~/src
install_location=/opt/freeswitch
version=1.6.20

# Compute useful variables
src=http://files.freeswitch.org/releases/freeswitch/freeswitch-${version}.tar.gz
archive_name=freeswitch-${version}.tar.gz
unpacked_dir_name=freeswitch-${version}

# Cleanup trap in case of error
cleanup() {
    if [ $? -ne 0 ]; then
        rm -rf "$install_location"
        rm -rf "$download_location"/"$unpacked_dir_name"
    fi
}

trap cleanup EXIT

# Update packages and install dependencies
apt-get update
apt-get install -y --no-install-recommends \
    wget whois build-essential git pkg-config uuid-dev zlib1g-dev libjpeg-dev \
    libsqlite3-dev libcurl4-openssl-dev libpcre3-dev libspeexdsp-dev \
    libssl-dev libedit-dev yasm liblua5.2-dev libopus-dev libsndfile-dev \
    libavformat-dev libavresample-dev libswscale-dev libldns-dev libpng-dev

# Make download and install directories
mkdir -p "$download_location" "$install_location"

# Download and unpack the source archive
pushd "$download_location"
if [ ! -f "$archive_name" ]; then # Download if not exists
    wget -O "$archive_name" "$src"
fi
tar -xvf "$archive_name"

pushd "$unpacked_dir_name"

# Enable non-default modules
sed -i -e "s,#applications/mod_av,applications/mod_av," modules.conf

# Compile and install
CFLAGS=-Wno-unused CXXFLGAS=-Wno-unused ./configure --prefix=${install_location}
make -j 4
make install