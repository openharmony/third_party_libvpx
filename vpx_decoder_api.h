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

#ifndef VPX_DECODER_API_H_
#define VPX_DECODER_API_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vpx/vpx_decoder.h"
#include "vpx/vpx_encoder.h"

#include "./tools_common.h"
#include "./video_reader.h"
#include "./vpx_config.h"

#ifdef __cplusplus
extern "C" {
#endif

int vpx_create_decoder_api(void ** vpxDecoder, const char *name);
int vpx_codec_decode_api(void * vpxDecoder, const unsigned char *frame, unsigned int frame_size);
int vpx_codec_get_frame_api(void * vpxDecoder, vpx_image_t **outputImg);
int vpx_destroy_decoder_api(void ** vpxDecoder);

#ifdef __cplusplus
} // extern "C"
#endif
#endif // VPX_DECODER_API_H_
