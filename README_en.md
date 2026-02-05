# libvpx in OpenHarmony
## Overview
The repository includes the third-party open-source software libvpx, which is a video codec implementation for the VP8 and VP9 standards. In OpenHarmony, libvpx serves as a fundamental component of the media subsystem, providing VP8 and VP9 video streams decoding capabilities for AVCodec.

Original Repository：https://chromium.googlesource.com/webm/libvpx
## Directory Structure
```
//third_party_libvpx
|-- BUILD.gn       # GN build configuration file, defines build rules and dependencies.
|-- bundle.json    # Component package configuration file, describes component information and dependencies.
|-- armv7_config   # armv7 configuration files.
|-- armv8_config   # armv8 configuration files.
|-- build          # Build system directory, contains build tools and scripts
|-- build_debug    # Debug build output directory
|-- examples       # Example code directory
|-- test           # Test code directory
|-- third_party    # Third-party dependencies directory
|-- tools          # Utility tools directory
|-- vp8            # VP8 decoder core implementation
|-- vp9            # VP9 decoder core implementation
|-- vpx            # VPX main interface and common definitions
|-- vpx_dsp        # DSP signal-processing module
|-- vpx_mem        # Memory-management module
|-- vpx_ports      # Platform-abstraction layer
|-- vpx_scale      # Image-scaling module
|-- vpx_util       # Utilities and general-purpose functions
```
## Compliance Requirements
According to the OpenHarmony PCS ([Product Compatibility Specification](https://www.openharmony.cn/systematic)):

(1) If VP8 decoding is supported, the recommended VP8 decoding capability is at least 1080p@30fps.

(2) If VP9 decoding is supported, the recommended VP9 decoding capability is at least 1080p@30fps(Profile 0, Profile 1, level 4.0).

## Using libvpx in OpenHarmony
The AVCodec component provides OpenHarmony with a unified video decoding capability. Refer to the [AVCodec Architecture Diagram](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/README_zh.md) for an overview.
Specifically：

(1) The framework layer exposes APIs to application developers: [obtain supported codecs](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/media/avcodec/obtain-supported-codecs.md)， [checking the codec profile and level supported](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/media/avcodec/obtain-supported-codecs.md#checking-the-codec-profile-and-level-supported)。

(2) In the service layer, the software decoder module wraps the dav1d.

### Build Configuration
(1) The `AVCodec` component integrates and utilizes the VP8 and VP9 decoding capabilities of the `libvpx` component by referencing it in its BUILD.gn file:
```gn
// BUILD.gn
external_deps += ["libvpx:vpxdec_ohos"]
```
(2) The `AVCodec` component declares the features `av_codec_support_vp8_decoder` and `av_codec_support_vp9_decoder` in its [bundle.json](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/bundle.json). These features are initialized in [Config.gni](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/config.gni) as follows:
```gn
declare_args() {
    av_codec_support_vp8_decoder = true    // Setting it to true enables VP8 soft decoding by default
    av_codec_support_vp9_decoder = true    // Setting it to true enables VP9 soft decoding by default
}
```

### Decoder Creation
```
            +------------------+      +-----------------------------+
            |   CodecServer    |----->|   CodecFactory              |
            +------------------+      +-----------------------------+
            | - codec:CodecBase|      | + createByName():CodecBase  |
            +------------------+      +-----------------------------+
                                            | calls static method createByName()
                              +-------------+------------+
                              |                          |
                    +---------v---------+       +--------v----------+
                    | VP8DecoderLoader  |       | VP9DecoderLoader  |
                    +-------------------+       +-------------------+
                    | + createByName()  |       | + createByName()  |
                    |    :CodecBase     |       |    :CodecBase     |
                    +-------|-----------+       +--------|----------+
                            | inherit            inherit | 
                        +---▼----------------------------▼-----+
                        |           VideoCodecLoader           |
                        +--------------------------------------+
                                            | use
                                    +-------v---------+
                                    |   CodecBase     | 
                                    +-------▲---------+ 
                                            | implement
                                    +-----------------+
                                    |   VpxDecoder    |
                                    +-----------------+
                             Figure 1: AVCodec VpxDecoder creation process
```
(1) In the AVCodec service layer, CodecServer uses [CodecFactory](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/services/services/codec/server/video/codec_factory.cpp) to invoke the static method CreateByName() of VP8DecoderLoader/VP9DecoderLoader, which creates an VP8/VP9 decoder(`VpxDecoder`).

(2) `VpxDecoder` is a wrapper around the AV1 decoder from **libvpx**. It also provides a capability query function, GetCodecCapability(std::vector<CapabilityData>& capaArray), which reports the supported capabilities such as Profile and Level.

(3) The Profiles and Levels are fully defined in [avcodec_info.h](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/inner_api/native/avcodec_info.h):
```C
enum VP9Profile {
    VP9_PROFILE_0 = 0,
    VP9_PROFILE_1 = 1,
    VP9_PROFILE_2 = 2,
    VP9_PROFILE_3 = 3,
};

enum VP9Level {
    VP9_LEVEL_1 = 0,
    VP9_LEVEL_11 = 1,
    VP9_LEVEL_2 = 2,
    ...
    VP9_LEVEL_6 = 11,
    VP9_LEVEL_61 = 12,
    VP9_LEVEL_62 = 13,
};
```
Additionally, Profile and Level are exposed in native_avcodec_base.h in both [SDK](https://gitcode.com/openharmony/interface_sdk_c/blob/master/multimedia/av_codec/native_avcodec_base.h) and [AVCodec](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/kits/c/native_avcodec_base.h). These definitions serve as the public API for application developers.

```C
typedef enum OH_VP9Profile {
    VP9_PROFILE_0 = 0,
    VP9_PROFILE_1 = 1,
    VP9_PROFILE_2 = 2,
    VP9_PROFILE_3 = 3,
} OH_VP9Profile;

typedef enum OH_VP9Level {
    VP9_LEVEL_1 = 0,
    VP9_LEVEL_11 = 1,
    VP9_LEVEL_2 = 2,
    ...
    VP9_LEVEL_6 = 11,
    VP9_LEVEL_61 = 12,
    VP9_LEVEL_62 = 13,
} OH_VP9Level;
```
Full documentation is available:[OH_VP9Profile](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcodec-base-h.md#oh_vp9profile), [OH_VP9level](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcodec-base-h.md#oh_vp9level).

## Vendor Customization
(1) VP8/VP9 software decoding is an optional capability in OpenHarmony. You can enable or disable VP8/VP9 software decoding via product-specific configuration. The configuration file can be locate at:

    //vendor/${product_company}/${product_name}/config.json

The configuration can be set as shown below: set `av_codec_support_vp8_decoder` to true to enable VP8 software decoding, or false to disable it and set `av_codec_support_vp9_decoder` to true to enable VP9 software decoding, or false to disable it:
```json
"multimedia:av_codec": {
    "features": {
        "av_codec_support_vp8_decoder": false, // VP8 software decoding is disabled
        "av_codec_support_vp9_decoder": false, // VP9 software decoding is disabled
    }
}
```
(2) Vendors may adjust the supported VP9 Profile and Level according to the device’s CPU performance and system capabilities by modifying the values assigned to the output parameter capaArray in the GetCodecCapability function in the source code below:

    //foundation/multimedia/av_codec/services/engine/codec/video/vpxdecoder/vpxDecoder.cpp

```cpp
void VpxDecoder::GetVP9CapProf(std::vector<CapabilityData> &capaArray)
{
    ...
    CapabilityData &capsData = capaArray.back();
    ...
    // Assign supported profiles, e.g., VP9 Profile 0, Profile 1
    capsData.profile = {
        static_cast<int32_t>(VP9_PROFILE_0),
        static_cast<int32_t>(VP9_PROFILE_1)
    };
    std::vector<int32_t> levels;
    // Emplace supported levels for Profile 0(e.g., up to Level 4.0)
    for (int32_t j = 0; j <= static_cast<int32_t>(VP9Level::VP9_LEVEL_40); j++) {
        levels.emplace_back(j);
    }
    capsData.profileLevelsMap.insert({static_cast<int32_t>(VP9_PROFILE_0), levels});
    ...
}
```
If support for the VP9 Profile 2(10-bit, 12-bit) and Profile 3(10-bit, 12-bit) are required, the graphics system (specifically SurfaceBuffer) must support 10-bit and 12-bit color depth.

(3) Additionally, for hardware decoding:
In the service layer, CodecFactory invokes the static method CreateByName() of HCodecLoader to create HCodec/HCodecList, which then interact with the HAL/hardware decoder through the HDI. Vendors must implement and adapt their hardware decoders to comply with the requirements of the HDI interface.

## License
For license details, see the LICENSE file in the root directory for details.