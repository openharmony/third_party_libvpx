#!/bin/bash
# make vpx_config.h

set -e

OUTPUT_DIR="$1"
CPU="$2"

if [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 <output_dir> <cpu>"
  exit 1
fi

mkdir -p $OUTPUT_DIR
rm -f "$OUTPUT_DIR/vpx_config.h"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

if [ ! -f "./configure" ]; then
  echo "ERROR: configure not found in $SCRIPT_DIR"
  exit 1
fi

if [ "$CPU" == "arm64" ]; then
  ./configure \
      --target=armv8-linux-gcc  \
      --enable-vp9-highbitdepth \
      --disable-vp8-encoder \
      --disable-vp9-encoder \
      --disable-unit-tests   \
      --disable-examples \
      --disable-pic    \
      --disable-libyuv  \
      --disable-webm-io  \
      --disable-sve
fi

if [ "$CPU" == "arm" ]; then
  ./configure \
      --target=armv7-linux-gcc  \
      --enable-vp9-highbitdepth \
      --disable-vp8-encoder \
      --disable-vp9-encoder \
      --disable-unit-tests   \
      --disable-examples \
      --disable-pic    \
      --disable-libyuv  \
      --disable-webm-io  \
      --disable-sve  \
      --disable-neon
fi

sed -i 's/#define HAVE_NEON[[:space:]]*0/#define HAVE_NEON 1/' vpx_config.h
sed -i 's/#define CONFIG_INSTALL_DOCS[[:space:]]*1/#define CONFIG_INSTALL_DOCS 0/' vpx_config.h
sed -i 's/#define HAVE_NEON_DOTPROD[[:space:]]*1/#define HAVE_NEON_DOTPROD 0/' vpx_config.h
sed -i 's/#define HAVE_NEON_I8MM[[:space:]]*1/#define HAVE_NEON_I8MM 0/' vpx_config.h
sed -i 's/#define HAVE_SVE[[:space:]]*1/#define HAVE_SVE 0/' vpx_config.h
sed -i 's/#define HAVE_SVE2[[:space:]]*1/#define HAVE_SVE2 0/' vpx_config.h
sed -i 's/#define CONFIG_POSTPROC[[:space:]]*1/#define CONFIG_POSTPROC 0/' vpx_config.h
sed -i 's/#define CONFIG_MULTITHREAD[[:space:]]*0/#define CONFIG_MULTITHREAD 1/' vpx_config.h
sed -i 's/#define CONFIG_RUNTIME_CPU_DETECT[[:space:]]*1/#define CONFIG_RUNTIME_CPU_DETECT 0/' vpx_config.h

cp vpx_config.h "$OUTPUT_DIR/"
rm -f vpx_config.h
