#!/bin/bash
#
# build static coreutils because we need exercises in minimalism
# MIT licensed: google it or see robxu9.mit-license.org.
#
# For Linux, also builds musl for truly static linking.

set -e

coreutils_version="8.28"

if [ -d build ]; then
  echo "= removing previous build directory"
  rm -rf build
fi

mkdir build # make build directory
pushd build

# download tarballs
echo "= downloading coreutils"
curl -LO http://ftp.gnu.org/gnu/coreutils/coreutils-${coreutils_version}.tar.xz

echo "= extracting coreutils"
tar xJf coreutils-${coreutils_version}.tar.xz

if ! [[ "$(cat /etc/*-release)" =~ alpine ]]; then
  echo "Please build on alpine linux"
fi

echo "= setting CC to musl-gcc"
export CC=gcc
export CFLAGS="-static"

echo "= building coreutils"

pushd coreutils-${coreutils_version}
env FORCE_UNSAFE_CONFIGURE=1 CFLAGS="$CFLAGS -Os -ffunction-sections -fdata-sections" LDFLAGS='-Wl,--gc-sections' ./configure
make
popd # coreutils-${coreutils_version}

popd # build

if [ ! -d releases ]; then
  mkdir releases
fi

echo "= strip & compress"
shopt -s extglob
set +e
while read -r file
do
  strip -s -R .comment -R .gnu.version --strip-unneeded "$file"
	upx --ultra-brute "$file"
done < <(ls "build/coreutils-${coreutils_version}/src/"!(*.*))
set -e

echo "= extracting coreutils binary"
cp build/coreutils-${coreutils_version}/src/!(*.*) releases

echo "= done"
