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
rm -f "$OUTPUT_DIR/vp8_rtcd.h" "$OUTPUT_DIR/vp9_rtcd.h" \
  "$OUTPUT_DIR/vpx_dsp_rtcd.h" "$OUTPUT_DIR/vpx_scale_rtcd.h"

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

if [ "$CPU" == "x86_64" ]; then
  ./configure \
      --target=generic-gnu \
      --enable-vp9-highbitdepth \
      --disable-vp8-encoder \
      --disable-vp9-encoder \
      --disable-unit-tests \
      --disable-examples \
      --disable-tools \
      --disable-docs \
      --disable-pic \
      --disable-libyuv \
      --disable-webm-io \
      --disable-runtime-cpu-detect

  cat > rtcd_config.mk <<'EOF'
CONFIG_RUNTIME_CPU_DETECT=no
CONFIG_VP8_DECODER=yes
CONFIG_VP8_ENCODER=no
CONFIG_VP9=yes
CONFIG_VP9_DECODER=yes
CONFIG_VP9_ENCODER=no
CONFIG_VP9_HIGHBITDEPTH=yes
CONFIG_SPATIAL_RESAMPLING=yes
CONFIG_POSTPROC=no
CONFIG_MULTITHREAD=yes
CONFIG_WEBM_IO=no
CONFIG_LIBYUV=no
EOF

  perl build/make/rtcd.pl --arch=generic --sym=vp8_rtcd \
      --config=rtcd_config.mk vp8/common/rtcd_defs.pl > vp8_rtcd.h
  perl build/make/rtcd.pl --arch=generic --sym=vp9_rtcd \
      --config=rtcd_config.mk vp9/common/vp9_rtcd_defs.pl > vp9_rtcd.h
  perl build/make/rtcd.pl --arch=generic --sym=vpx_dsp_rtcd \
      --config=rtcd_config.mk vpx_dsp/vpx_dsp_rtcd_defs.pl > vpx_dsp_rtcd.h
  perl build/make/rtcd.pl --arch=generic --sym=vpx_scale_rtcd \
      --config=rtcd_config.mk vpx_scale/vpx_scale_rtcd.pl > vpx_scale_rtcd.h

  sed -i 's/#define CONFIG_INSTALL_DOCS[[:space:]]*1/#define CONFIG_INSTALL_DOCS 0/' vpx_config.h
  sed -i 's/#define CONFIG_POSTPROC[[:space:]]*1/#define CONFIG_POSTPROC 0/' vpx_config.h
  sed -i 's/#define CONFIG_MULTITHREAD[[:space:]]*0/#define CONFIG_MULTITHREAD 1/' vpx_config.h
  sed -i 's/#define CONFIG_RUNTIME_CPU_DETECT[[:space:]]*1/#define CONFIG_RUNTIME_CPU_DETECT 0/' vpx_config.h

  cp vpx_config.h vp8_rtcd.h vp9_rtcd.h vpx_dsp_rtcd.h vpx_scale_rtcd.h "$OUTPUT_DIR/"
  rm -f rtcd_config.mk
  rm -f vpx_config.h vp8_rtcd.h vp9_rtcd.h vpx_dsp_rtcd.h vpx_scale_rtcd.h
  exit 0
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
