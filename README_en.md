# libvpx
Original Repository：https://chromium.googlesource.com/webm/libvpx

The repository includes the third-party open-source software libvpx, which is a video codec implementation for the VP8 and VP9 standards. In OpenHarmony, libvpx serves as a fundamental component of the media subsystem, providing VP8 and VP9 video streams decoding capabilities for AVCodec.
## Directory Structure
```
//third_party_libvpx
|-- BUILD.gn       # GN build configuration file, defines build rules and dependencies
|-- bundle.json    # Component package configuration file, describes component information and dependencies
|-- build          # Build system directory, contains build tools and scripts
|-- build_debug    # Debug build output directory
|-- examples       # Example code directory
|-- test           # Test code directory
|-- third_party    # Third-party dependencies directory
|-- tools          # Tools and utilities directory
|-- vp8            # VP8 decoder core implementation
|-- vp9            # VP9 decoder core implementation
|-- vpx            # VPX main interface and common definitions
|-- vpx_dsp        # DSP signal-processing module
|-- vpx_mem        # Memory-management module
|-- vpx_ports      # Platform-abstraction layer
|-- vpx_scale      # Image-scaling module
|-- vpx_util       # Utilities and general-purpose functions
```
## How to Use libvpx in OpenHarmony
System components in OpenHarmony need to reference the libvpx component in BUILD.gn to use it.
```
// BUILD.gn
external_deps + = [libvpx:vpxdec_ohos]
```
### vpx_codec_err_t Error Codes
The following are the vpx_codec_err_t error codes defined in vpx/vpx_codec.h.

| Error Code | Description                                                                 |
| --------------------------- | ---------------------------------------                    |
| VPX_CODEC_OK                | Operation completed without error.                         |
| VPX_CODEC_ERROR             | Unspecified error.                                         |
| VPX_CODEC_MEM_ERROR         | Memory operation failed.                                   |
| VPX_CODEC_ABI_MISMATCH      | ABI version mismatch.                                      |
| PX_CODEC_INCAPABLE          | Algorithm does not have required capability.               |
| VPX_CODEC_UNSUP_BITSTREAM   | The given bitstream is not supported.                      |
| VPX_CODEC_UNSUP_FEATURE     | Encoded bitstream uses an unsupported feature.             |
| VPX_CODEC_CORRUPT_FRAME     | The coded data for this stream is corrupt or incomplete.   |
| VPX_CODEC_INVALID_PARAM     | An application-supplied parameter is not valid.            |
| VPX_CODEC_LIST_END          | An iterator reached the end of list.                       |
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
See the LICENSE file in the root directory for details.
