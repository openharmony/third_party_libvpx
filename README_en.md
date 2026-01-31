# libvpx
Original Repository：https://chromium.googlesource.com/webm/libvpx

The repository includes the third-party open-source software libvpx, which is a video codec implementation for the VP8 and VP9 standards. In OpenHarmony, libvpx serves as a fundamental component of the media subsystem, providing VP8 and VP9 video streams decoding capabilities for AVCodec.
## Directory Structure
```
//third_party_libvpx
|-- BUILD.gn       # GN build configuration file, defines build rules and dependencies. Added by OpenHarmony
|-- bundle.json    # Component package configuration file, describes component information and dependencies. Added by OpenHarmony
|-- armv7_config   # armv7 configuration files. Added by OpenHarmony
|-- armv8_config   # armv8 configuration files. Added by OpenHarmony
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

## Feature Support
**Since：** 6.1
(1)  When the application attempt to create a decoder according to the [platform rules](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/media/avcodec/avcodec-support-formats.md), the system preferentially creates a hardware decoder instance. If the system does not support hardware decoding or the hardware decoder resources are insufficient, the system creates a software decoder instance.

(2) VP8/VP9 software decoding is an optional capability in OpenHarmony. you can enable/disable the feature via your own product configuration. The product configuration path can be as follows: 
```
//vendor/${pruduct_company}/${product_name}/config.json
```
The configuration can be set as shown below:
```json
"multimedia:av_codec": {
    "features": {
        "av_codec_support_vp8_decoder：": false,
        "av_codec_support_vp9_decoder：": false,
    }
}
```
(3) According to the OpenHamony PCS ([Product Compatibility Specification](https://www.openharmony.cn/systematic)), If VP8 decoding is supported, the recommended VP8 decoding capability is at least 1080p@30fps.

(4) According to the OpenHamony PCS ([Product Compatibility Specification](https://www.openharmony.cn/systematic)), If AV9 decoding is supported, the recommended VP9 decoding capability is at least 1080p@30fps(Profile 0、Profile 1, level 4.0). You can modify the supported Profile and Level in the AVCodec, the path is as follows：
```
//foundation/multimedia/avcodec/services/engine/codec/video/vpxdecoder/vpxDecoder.cpp
```
and the function:
```C++
void Av1Decoder::GetVP9CapProf(std::vector<CapabilityData> &capaArray)
{
    ...
    CapabilityData &capsData = capaArray.back();
    ...
    // Assign supported profiles, e.g., VP9 Profile 0, Profile 1
    capsData.profile = {
        static_cast<int32_t>(VP9_PROFILE_0),
        static_cast<int32_t>(VP9_PROFILE_1)
    };
    std::vector<int32_t> levels；
    // Assign supported levels for the profile, e.g., level 4.0
    for (int32_t j = 0; j <= static_cast<int32_t>(VP9Level::VP9_LEVEL_40); j++) {
        levels.emplace_back(j);
    }
    capsData.profileLevelsMap.insert({static_cast<int32_t>(VP9_PROFILE_0), levels});
    ...
}
```
According to the AV1 standard, the above Profiles and Levels are fully defined in [avcodec_info.h](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/inner_api/native/avcodec_info.h):
```C
enum AV1Profile : int32_t {
    AV1_PROFILE_MAIN = 0,
    AV1_PROFILE_HIGH = 1,
    AV1_PROFILE_PROFESSIONAL = 2,
};

enum AV1Level : int32_t {
    AV1_LEVEL_20 = 0,
    AV1_LEVEL_21 = 1,
    AV1_LEVEL_22 = 2,
    ...
    AV1_LEVEL_72 = 22,
    AV1_LEVEL_73 = 23,
};
```
If application developers need to be aware of them, the definitions must also be included in both the [SDK](https://gitcode.com/openharmony/interface_sdk_c/blob/master/multimedia/av_codec/native_avcodec_base.h) and [AVCodec](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/kits/c/native_avcodec_base.h):
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

In addition, if support for the VP9 Profile 2, Profile 3 is required, the display system (specifically SurfaceBuffer) must support 12-bit color depth.

(4) Application developers can query the above configurations and capabilities through the AVCodec interface. see [Obtaining Supported Codecs](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/media/avcodec/obtain-supported-codecs.md#obtaining-supported-codecs), [Checking the Codec Profile and Level Supported](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/media/avcodec/obtain-supported-codecs.md#checking-the-codec-profile-and-level-supported).

## License
See the LICENSE file in the root directory for details.
