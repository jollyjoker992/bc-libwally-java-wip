#!/bin/bash

set -e

source scripts/helper.sh
source ../deps/libwally-core/tools/android_helpers.sh

# Set env var
. ./scripts/setenv.sh

ARCH_LIST=$(android_get_arch_list)
TOOLCHAIN_DIR=$(android_get_build_tools_dir)
JNI_MD_DIR="darwin"
JNI_LIBS=(bc-libwally-address-jni bc-libwally-bip32-jni bc-libwally-bip39-jni bc-libwally-crypto-jni bc-libwally-core-jni bc-libwally-script-jni)
LIBWALY_CORE_FILE=libwallycore.so

if ! is_osx; then
  JNI_MD_DIR="linux"
fi

# Install jni libs
for ARCH in $ARCH_LIST; do

  API=19
  if [[ $ARCH == *"64"* ]]; then
    API=21
  fi

  CC=$(android_get_build_tool "$ARCH" "$TOOLCHAIN_DIR" $API "clang")

  OUT_DIR=app/src/main/jniLibs/$ARCH
  mkdir -p "$OUT_DIR"

  for LIB in "${JNI_LIBS[@]}"; do
    LIB_NAME="lib${LIB}.so"
    echo "Building '$LIB_NAME' for '$ARCH'..."

    $CC -I"$JAVA_HOME"/include -I"$JAVA_HOME"/include/$JNI_MD_DIR -I"../deps/libwally-core/include" -shared -fPIC ../java/src/main/jniLibs/"${LIB}".c ../java/src/main/jniLibs/jni-utils.c -o "$OUT_DIR/$LIB_NAME" "$OUT_DIR/$LIBWALY_CORE_FILE"
    echo "'$ARCH/$LIB_NAME' Done!"
  done

done
