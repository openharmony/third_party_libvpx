/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

#include "vpx_dcoder_api.h"
#include <stdio.h>

int vpx_create_decoder_api(void ** vpxDecoder, const char *name) {
  const VpxInterface *decoder = NULL;
  vpx_codec_ctx_t * ctx = (vpx_codec_ctx_t *)malloc(sizeof(*ctx));
  
  decoder = get_vpx_decoder_by_name(name);
  if (!decoder) {
    printf("Unknown input codec!");
    return -1;
  }
  if (vpx_codec_dec_init(ctx, decoder->code_interface(), NULL, VPX_CODEC_USE_FRAME_THREADING)) {
    printf("Failed to initialize decoser.");
    return -1;
  }
  *vpxDecoder = ctx;
  return 0;
}

int vpx_codec_decode_api(void * vpxDecoder, const unsigned char *frame, unsigned int frame_size) {
  vpx_codec_ctx_t *codec = (vpx_codec_ctx_t *)vpxDecoder;
  int ret = vpx_codec_decode(codec, frame, (unsigned int)frame_size, NULL, 0);
  if (ret) {
    printf("Failed to decode frame.");
    return ret;
  }
  return 0;
}

int vpx_codec_get_frame_api(void * vpxDecoder, vpx_image_t **outputImg) {
  vpx_codec_ctx_t *codec = (vpx_codec_ctx_t *)vpxDecoder;
  vpx_codec_iter_t iter = NULL;
  *outputImg = vpx_codec_get_frame(codec, &iter);
  return 0;
}

int vpx_destroy_decoder_api(void ** vpxDecoder) {
  if(vpxDecoder == NULL || *vpxDecoder == NULL) {
    return -1;
  }
  vpx_codec_ctx_t *codec = (vpx_codec_ctx_t *)(*vpxDecoder);
  vpx_codec_err_t res = vpx_codec_destroy(codec);
  free(codec);
  *vpxDecoder = NULL;
  if (res != VPX_CODEC_OK) {
    printf("Failed to destroy decoder: %s\n",vpx_codec_err_to_string(res));
    return -1;
  }
  return 0;
}




