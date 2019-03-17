#!/bin/sh
#

export ANDROID_NDK=${ANDROID_NDK:-~/android-ndk-r19b}
export TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64

function do_ndk()
{
	${ANDROID_NDK}/ndk-build NDK_PROJECT_PATH=. NDK_APPLICATION_MK=Application.mk $1
}

if [[ $1 == "clean" ]]; then
	do_ndk "clean"
	exit
fi

autoreconf -i

export AR=$TOOLCHAIN/bin/aarch64-linux-android-ar
export AS=$TOOLCHAIN/bin/aarch64-linux-android-as
export CC=$TOOLCHAIN/bin/aarch64-linux-android21-clang
export CXX=$TOOLCHAIN/bin/aarch64-linux-android21-clang++
export LD=$TOOLCHAIN/bin/aarch64-linux-android-ld
export RANLIB=$TOOLCHAIN/bin/aarch64-linux-android-ranlib
export STRIP=$TOOLCHAIN/bin/aarch64-linux-android-strip

./configure --host aarch64-linux-android

# Avoid linker errors about missing localeconv
sed -i 's/#define HAVE_LOCALECONV 1/\/*#define HAVE_LOCALECONV 1*\//' jansson_private_config.h
cp jansson_private_config.h android/
# We want to use android/jansson_config.h
rm src/jansson_config.h

do_ndk
