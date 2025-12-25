# libvpx
Original Repository：https://github.com/webmproject/libvpx

The repository includes the third-party open-source software libvpx, which is a video codec implementation for the VP8 and VP9 standars. In OpenHarmony, libvpx serves as a fundamental component of the media subsystem, providing decoding capabilities for VP8 and VP9 video streams.
## Directory Structure
```
//third_party_libvpx
|-- BUILD.gn     
|-- bundle.json
|-- build
|-- build_debug
|-- examples
|-- test
|-- third_party
|-- tools
|-- vp8
|-- vp9
|-- vpx
|-- vpx_dsp
|-- vpx_mem
|-- vpx_ports
|-- vpx_scale
|-- vpx_util
```
## How to Use libvpx in OpenHarmony
System components in OpenHarmony need to reference the libvpx component in BUILD.gn to use it.
```
// BUILD.gn
external_deps + = [libvpx:vpxdec_ohos]
```
### Decoding Steps Using libvpx
（1）Create decoder
```
int vpx_create_decoder_api(void ** vpxDecoder, const char *name);
vpxDecoder:：decoder handler
name：name of decoder（vp8 or vp9）
return value：0 means success，1 means fail
```
（2）Decode one frame
```
int vpx_codec_decode_api(void * vpxDecoder, const unsigned char *frame, unsigned int frame_size)
vpxDecoder：decoder handler
frame：current frame bitstream buffer
frame_size：current frame bitstream size
return value：0 means success，1 means fail
```
（3）Get the decoded image
```
int vpx_codec_get_frame_api(void * vpxDecoder, vpx_image_t **outputImg) 
vpxDecoder：decoder handler
outputmg：decoded image
return value：0
```
（4）Destroy the decoder
```
int vpx_destroy_decoder_api(void ** vpxDecoder)
vpxDecoder：decoder handler
return value：0 means success，1 means fail
```
## Feature Support
OpenHarmony currently integrates only the decoding capability of libvpx, used to parse VP8 and VP9 bitstreams. Video encoding is not supported yet.
## License
See the LICENSE.md file in the root directory for details.