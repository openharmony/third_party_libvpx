# libvpx
原始仓来源：https://chromium.googlesource.com/webm/libvpx

仓库包含第三方开源软件libvpx，libvpx是VP8、VP9标准的视频编解码器。在OpenHarmony中，libvpx主要媒体子系统的基础部件，提供VP8、VP9码流的解码能力。
## 目录结构
```
//third_party_libvpx
|-- BUILD.gn       # GN构建配置文件，定义编译规则和依赖关系。由OpenHarmony增加
|-- bundle.json    # 组件包配置文件，描述组件信息和依赖。由OpenHarmony增加
|-- armv7_config   # armv7配置文件。由OpenHarmony增加
|-- armv8_config   # armv8配置文件。由OpenHarmony增加
|-- build          # 工程构建目录，编译构建工具、脚本等
|-- build_debug    # 调试版本构建目录
|-- examples       # 示例代码目录
|-- test           # 测试代码目录
|-- third_party    # 第三方依赖目录
|-- tools          # 工具程序目录
|-- vp8            # VP8解码器核心实现
|-- vp9            # VP9解码器核心实现
|-- vpx            # VPX主接口和公共定义
|-- vpx_dsp        # DSP信号处理模块
|-- vpx_mem        # 内存管理模块
|-- vpx_ports      # 平台移植层
|-- vpx_scale      # 图像缩放模块
|-- vpx_util       # 工具类和通用功能
```
## OpenHarmony如何使用libvpx
在OpenHarmony中，系统部件通过BUILD.gn文件引用libvpx部件，以集成并使用其VP8、VP9的解码能力。
```
// BUILD.gn
external_deps + = [libvpx:vpxdec_ohos]
```

## 功能支持说明
**以下说明适用起始版本：** 6.1

(1) 应用在创建VP8/VP9解码器时，按照[平台统一规则](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/media/avcodec/avcodec-support-formats.md)系统会优先创建硬件解码器，如无硬件解码器或则硬件解码器资源不足时创建软件解码器（当前AVCodec尚不支持AV1的硬解），如无解码能力则创建失败。

(2) VP8、VP9软解码均为OpenHamony中的可选能力。厂商可通过配置文件开关其软解码功能，配置文件路径可以如下：
```
//vendor/${pruduct_company}/${product_name}/config.json
```
配置方式可以如下，在av_codec部件节点的features中配置av_codec_support_av1_decoder：
```json
"multimedia:av_codec": {
    "features": {
        "av_codec_support_vp8_decoder：": false,
        "av_codec_support_vp9_decoder：": false,
    }
}
```
(3) 按[Openharmony产品兼容性规范](https://www.openharmony.cn/systematic)，若支持VP8软件解码时，VP8解码建议规格至少为1080p@30fps。

(4) 按[Openharmony产品兼容性规范](https://www.openharmony.cn/systematic)，若支持VP9软件解码时，VP9解码建议规格至少为1080p@30fps(profile 0、profile 1， level 4.0)。厂商可以在AVCodec源码中修改VP9支持的Profile与Level，路径如下：
```
//foundation/multimedia/avcodec/services/engine/codec/video/vpxdecoder/vpxDecoder.cpp
```
在GetVP9CapProf函数中，修改对出参capaArray(成员profileLevelsMap记录支持情况)的赋值，完成后重新编译：
```C++
void Av1Decoder::GetVP9CapProf(std::vector<CapabilityData> &capaArray)
{
    ...
    CapabilityData &capsData = capaArray.back();
    ...
    // 赋值支持的profile，例如支持VP9 Profile 0，Profile 1
    capsData.profile = {
        static_cast<int32_t>(VP9_PROFILE_0),
        static_cast<int32_t>(VP9_PROFILE_1)
    };
    std::vector<int32_t> levels；
    // 赋值profile下支持的level，例如Profile 0支持到level 4.0
    for (int32_t j = 0; j <= static_cast<int32_t>(VP9Level::VP9_LEVEL_40); j++) {
        levels.emplace_back(j);
    }
    capsData.profileLevelsMap.insert({static_cast<int32_t>(VP9_PROFILE_0), levels}); // 赋值profile下支持的level
    ...
}
```
上述Profile和Level均按照VP9标准进行了完整的定义，在AVCodec仓的[avcodec_info.h](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/inner_api/native/avcodec_info.h)中：
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
若需要应用开发者感知，还需要同时在[SDK仓](https://gitcode.com/openharmony/interface_sdk_c/blob/master/multimedia/av_codec/native_avcodec_base.h)和[AVCodec仓](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/kits/c/native_avcodec_base.h)的native_avcodec_base.h中定义:
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
完整的定义描述可见资料：[OH_VP9Profile](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcodec-base-h.md#oh_vp9profile)，[OH_VP9level](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcodec-base-h.md#oh_vp9level).

另外，若VP9需要支持profile 2、profile 3时，需要显示系统（中surfaceBuffer）支持12bit。

(4) 上述开关及能力的配置，应用开发者都可以通过AVCodec的接口查询到。详见[获取支持的编解码能力](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/media/avcodec/obtain-supported-codecs.md)， [查询编解码档次和级别支持情况](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/media/avcodec/obtain-supported-codecs.md#%E6%9F%A5%E8%AF%A2%E7%BC%96%E8%A7%A3%E7%A0%81%E6%A1%A3%E6%AC%A1%E5%92%8C%E7%BA%A7%E5%88%AB%E6%94%AF%E6%8C%81%E6%83%85%E5%86%B5)。

## License
详见仓库目录下的LICENSE文件
