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
（1）Decoder Initialization
```
vpx_codec_error_t vpx_codec_dec_init(vpx_codec_ctx_t *ctx, vpx_codec_iface_t *iface, const vpx_codec_dec_cfg_t *cfg, vpx_codec_flags_t flags)
ctx: Pointer to the decoder instance.
iface: Pointer to the codec algorithm interface to be used.
cfg: Configuration parameters for the decoder; may be NULL.
flags: A combination of VPX_CODEC_USE_* flags.
return value: Returns 0 on successful initialization; a non-zero value indicates failure. Refer to the vpx_codec_err_t enumeration for error code descriptions.

```
（2）Decode one frame
```
vpx_codec_err_t vpx_codec_decode(vpx_codec_ctx_t *ctx, const uint8_t *data, unsigned int data_sz, void *user_priv, long deadline)
ctx: Pointer to the decoder instance.
data: Pointer to the encoded data buffer for the current frame.
data_sz: Size (in bytes) of the encoded data.
user_priv: Optional user-defined private data associated with this frame; may be NULL.
deadline: Soft deadline (in microseconds) that the decoder should attempt to meet. Set to 0 if no deadline constraint is required.
return value: Returns 0 on success; a non-zero value indicates decoding failure. Refer to vpx_codec_err_t for error code details.

```
（3）Get the decoded image
```
vpx_image_t *vpx_codec_get_frame(vpx_codec_ctx_t *ctx, vpx_codec_iter_t *iter)
ctx: Pointer to the decoder instance.
iter: Iterator pointer; must be initialized to NULL on the first call.
return value: Returns a pointer to the decoded image frame, or NULL if no more frames are available.
```
（4）Destroy the decoder
```
vpx_codec_err_t vpx_codec_destroy(vpx_codec_ctx_t *ctx)
ctx: Pointer to the decoder instance.
return value: Returns 0 on successful destruction; a non-zero value indicates failure. Refer to vpx_codec_err_t for error code descriptions.

```
## Feature Support
OpenHarmony currently integrates only the decoding capability of libvpx, used to parse VP8 and VP9 bitstreams. Video encoding is not supported yet.
## License
See the LICENSE.md file in the root directory for details.