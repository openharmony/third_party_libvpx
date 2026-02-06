# third_party_libvpx
## 概述
本仓库集成第三方开源软件libvpx(VP8、VP9标准的视频编解码器的开源实现)。在OpenHarmony中，libvpx主要作为媒体子系统的基础部件，提供VP8、VP9码流的解码能力。

libvpx来源：https://chromium.googlesource.com/webm/libvpx
## 目录结构
```
//third_party_libvpx
|-- BUILD.gn       # GN构建配置文件，定义编译规则和依赖关系。
|-- bundle.json    # 组件包配置文件，描述组件信息和依赖。
|-- armv7_config   # armv7配置文件。
|-- armv8_config   # armv8配置文件。
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
## OpenHarmony对解码器的要求
根据[OpenHarmony产品兼容性规范](https://www.openharmony.cn/systematic)：

(1) 若支持VP8软件解码时，VP8解码建议规格至少为1080p@30fps。

(2) 若支持VP9软件解码时，VP9解码建议规格至少为1080p@30fps(profile 0、profile 1， level 4.0)。

## OpenHarmony如何使用libvpx
部件AVCodec为OpenHarmony提供了统一的视频解码能力，参考[AVCode 框架图](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/README_zh.md)，其中：

(1) 框架层的编解码框架对应用开发者提供接口，例如：[获取支持的编解码能力](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/media/avcodec/obtain-supported-codecs.md)， [查询编解码档次和级别支持情况](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/media/avcodec/obtain-supported-codecs.md#%E6%9F%A5%E8%AF%A2%E7%BC%96%E8%A7%A3%E7%A0%81%E6%A1%A3%E6%AC%A1%E5%92%8C%E7%BA%A7%E5%88%AB%E6%94%AF%E6%8C%81%E6%83%85%E5%86%B5)。

(2) 服务层中的软件解码器模块将对libvpx进行加载和封装。

### 集成与配置

部件AVCodec通过feature配置的方式来使能VP8、VP9软解码。

(1) 声明：AVCodec仓的[bundle.json](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/bundle.json)里声明的features：av_codec_support_vp8_decoder、av_codec_support_vp9_decoder分别用于使能VP8、VP9软解码。

(2) 定义与赋值：多条件判断是否使能VP8或VP9解码器。
* 在AVCodec仓[Config.gni](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/config.gni)中通过declare_args()定义并默认使能VP8和VP9软解码。
* 产品配置feature的值会覆盖上述默认值，参考[产品如何配置部件的feautre](https://gitcode.com/openharmony/build/blob/master/docs/%E9%83%A8%E4%BB%B6%E5%8C%96%E7%BC%96%E8%AF%91%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5.md#11-%E4%BA%A7%E5%93%81%E5%A6%82%E4%BD%95%E9%85%8D%E7%BD%AE%E9%83%A8%E4%BB%B6%E7%9A%84feature)。
* AVCodec仓的[Config.gni](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/config.gni)会校验部件dav1d是否被裁剪。如果部件[被裁剪](https://gitcode.com/openharmony/build/blob/master/docs/%E9%83%A8%E4%BB%B6%E5%8C%96%E7%BC%96%E8%AF%91%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5.md)，则不使能AV1软解码。
```

// Config.gni
declare_args() {
    // 初始化true，表示默认开启VP8软解码
    av_codec_support_vp8_decoder = true         

    // 初始化true，表示默认开启VP9软解码
    av_codec_support_vp9_decoder = true
}

// 如果产品裁剪了部件libvpx，将不开启VP8和VP9软解码
if (!defined(global_parts_info) || !defined(global_parts_info.multimedia_libvpx)) {
    av_codec_support_vp8_decoder = false
    av_codec_support_vp9_decoder = false
}
```

(3) 使用：AVCodec仓的[BUILD.gn](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/services/engine/codec/video/BUILD.gn)通过判断是否使能VP8或VP9解码器来决定是否引用部件libvpx，以集成并使用其VP8、VP9的解码能力。
```
// BUILD.gn
if (av_codec_support_vp8_decoder || av_codec_support_vp9_decoder) {
    external_deps += ["libvpx:vpxdec_ohos"]
}
```

### 实现与调用
```
            +------------------+      +-----------------------------+
            |   CodecServer    |----->|   CodecFactory              |
            +------------------+      +-----------------------------+
            | - codec:CodecBase|      | + createByName():CodecBase  |
            +------------------+      +-----------------------------+
                                            | 调用静态方法
                              +-------------+------------+
                              |                          |
                    +---------v---------+       +--------v----------+
                    | VP8DecoderLoader  |       | VP9DecoderLoader  |
                    +-------------------+       +-------------------+
                    | + createByName()  |       | + createByName()  |
                    |    :CodecBase     |       |    :CodecBase     |
                    +-------|-----------+       +--------|----------+
                            | 继承                   继承 | 
                        +---▼----------------------------▼-----+
                        |           VideoCodecLoader           |
                        +--------------------------------------+
                                            | 使用
                                    +-------v---------+
                                    |   CodecBase     | 
                                    +-------▲---------+ 
                                            | 实现
                                    +-----------------+
                                    |   VpxDecoder    |
                                    +-----------------+
                             图1 AVCodec服务层VP8/VP9软件解码器创建示意图
```
(1) AVCodec服务层中CodecServer通过[CodecFactory](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/services/services/codec/server/video/codec_factory.cpp)，调用Vp8DecoderLoader，Vp9DecoderLoader的静态方法CreateByName()分别创建VP8、VP9的解码器(`VpxDecoder`)。

(2) `VpxDecoder`即是对**libvpx**中VP8、VP9解码器的封装，向AVCodec提供统一的解码接口，实现能力查询函数GetCodecCapability(std::vector<CapabilityData> &capaArray)，即实现对包括Profile与Level在内的能力信息查询。

(3) AVCodec仓的[avcodec_info.h](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/inner_api/native/avcodec_info.h)中对Profile和Level进行了完整的定义：
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
同时在[SDK仓](https://gitcode.com/openharmony/interface_sdk_c/blob/master/multimedia/av_codec/native_avcodec_base.h)和[AVCodec仓](https://gitcode.com/openharmony/multimedia_av_codec/blob/master/interfaces/kits/c/native_avcodec_base.h)的native_avcodec_base.h中定义了Profile和Level，作为应用开发者的接口，详细描述见[OH_VP9Profile](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcodec-base-h.md#oh_vp9profile)，[OH_VP9level](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcodec-base-h.md#oh_vp9level):
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

## 能力定制说明
(1) OpenHarmony将VP8、VP9软解码作为可选能力，厂商可通过在config.json中装配部件libvpx并使能部件AVCodec特性来开启软解码能力：
* 装配部件libvpx
  * 参考[装配部件](https://gitcode.com/openharmony/docs/blob/master/zh-cn/design/OpenHarmony%E9%83%A8%E4%BB%B6%E8%AE%BE%E8%AE%A1%E5%92%8C%E5%BC%80%E5%8F%91%E6%8C%87%E5%8D%97.md#%E8%A3%85%E9%85%8D%E9%83%A8%E4%BB%B6)，配置文件路径可以是`//vendor/${product_company}/${product_name}/config.json`    
  * 装配时内容可以如下：
```json
{
  ...
  "subsystems": [{
      "subsystem": "thirdparty",
      "components": [{
          "component": "libvpx",  // 装配部件libvpx
          "features": []
        }]
    }]
}
```
* 配置AVCodec特性，参考[配置特性](https://gitcode.com/openharmony/docs/blob/master/zh-cn/design/OpenHarmony%E9%83%A8%E4%BB%B6%E8%AE%BE%E8%AE%A1%E5%92%8C%E5%BC%80%E5%8F%91%E6%8C%87%E5%8D%97.md#%E9%85%8D%E7%BD%AE%E7%89%B9%E6%80%A7)，在上述config.json中装配部件AVCodec的同时配置特性av_codec_support_vp8_decoder, 值为true表示开启VP8软解码，false表示关闭VP8软解码；配置特性av_codec_support_vp9_decoder，值为true表示开启VP9软解码，false表示关闭VP9软解码：
```json
{
  {
    "subsystem": "multimedia",
    "components": [{
        "component": "av_codec",   // 配置部件AVCodec的特性
        "features": [ 
            "av_codec_support_vp8_decoder = true", // 配置特性为true，表示开启VP8软解码
            "av_codec_support_vp9_decoder = true"  // 配置特性为true，表示开启VP9软解码
        ] 
      }]
  }
}
```
(2) 厂商可根据自身的CPU性能及系统能力修改VP9支持的Profile与Level，即在如下源码中修改函数GetVP9CapProf出参capaArray的赋值，完成后需重新编译相关组件，可通过[OH_AVCapability_GetSupportedProfiles](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcapability-h.md#oh_avcapability_getsupportedprofiles)，[OH_AVCapability_GetSupportedLevelsForProfile](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis-avcodec-kit/capi-native-avcapability-h.md#oh_avcapability_getsupportedlevelsforprofile)接口获取实际支持的Profile与Level情况来验证：
```
    //foundation/multimedia/av_codec/services/engine/codec/video/vpxdecoder/vpxDecoder.cpp
```

```cpp
void VpxDecoder::GetVP9CapProf(std::vector<CapabilityData> &capaArray)
{
    ...
    CapabilityData &capsData = capaArray.back();
    ...
    // 赋值支持的profile，例如支持VP9 Profile 0，Profile 1
    capsData.profile = {
        static_cast<int32_t>(VP9_PROFILE_0),
        static_cast<int32_t>(VP9_PROFILE_1)
    };
    std::vector<int32_t> levels;
    // 为Profile设置支持的Level范围，例如为Profile 0最高支持到Level 4.0
    for (int32_t j = 0; j <= static_cast<int32_t>(VP9Level::VP9_LEVEL_40); j++) {
        levels.emplace_back(j);
    }
    capsData.profileLevelsMap.insert({static_cast<int32_t>(VP9_PROFILE_0), levels}); // 能力信息写入输出参数
    ...
}
```
注：配置VP9支持Profile 2(10-bit、12-bit)、Profile 3(10-bit、12-bit)时，依赖OH图形系统（的SurfaceBuffer）支持10-bit和12-bit，否则会出现内存申请失败导致解码器初始化失败。

(3) 另外，libvpx仅适用于软件解码。对`硬件解码`场景：服务层CodecFactory调用`HCodecLoader`的静态方法CreateByName()创建HCodec/HCodecList，它们通过HDI接口调用HAL或硬件解码器，厂商需适配并满足`HDI`接口的要求。
## License
具体许可条款请参见仓库根目录下的 LICENSE 文件。
