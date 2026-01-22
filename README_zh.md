# libvpx
原始仓来源：https://chromium.googlesource.com/webm/libvpx

仓库包含第三方开源软件libvpx，libvpx是VP8、VP9标准的视频编解码器。在OpenHarmony中，libvpx主要媒体子系统的基础部件，提供VP8、VP9码流的解码能力。
## 目录结构
```
//third_party_libvpx
|-- BUILD.gn       # GN构建配置文件，定义编译规则和依赖关系
|-- bundle.json    # 组件包配置文件，描述组件信息和依赖
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
在OpenHarmony中，系统部件通过BUILD.gn文件引用libvpx部件，以集成并使用其编解码能力。
```
// BUILD.gn
external_deps + = [libvpx:vpxdec_ohos]
```
### vpx_codec_err_t错误码说明
以下为vpx/vpx_codec.h中的vpx_codec_err_t错误码。

| 错误码 | 错误信息                                        |
| -------- | ---------------------------------------     |
| VPX_CODEC_OK                | 操作成功完成，无错误。       |
| VPX_CODEC_ERROR             | 未指定的错误。              |
| VPX_CODEC_MEM_ERROR         | 内存操作失败。              |
| VPX_CODEC_ABI_MISMATCH      | 版本不匹配。                |
| PX_CODEC_INCAPABLE          | 算法不具备所需功能。         |
| VPX_CODEC_UNSUP_BITSTREAM   | 给定的码流不受支持。         |
| VPX_CODEC_UNSUP_FEATURE     | 编码码流使用了不受支持的功能。 |
| VPX_CODEC_CORRUPT_FRAME     | 该码流的数据已损坏或不完整。  |
| VPX_CODEC_INVALID_PARAM     | 应用程序提供的参数无效。     |
| VPX_CODEC_LIST_END          | 迭代器已到达列表末尾。       |

### 使用libvpx库解码步骤
（1）解码器初始化
```
vpx_codec_error_t vpx_codec_dec_init(vpx_codec_ctx_t *ctx, vpx_codec_iface_t *iface, cfg, vpx_codec_flags_t flags)
ctx：指向该解码器实例的指针
iface：指向要使用的编解码算法的指针
cfg：使用的配置参数，可为NULL
flags：由VPX_CODEC_USE_*标志组成的
返回值：0解码器初始化成功，非0解码器初始化失败，参考vpx_codec_err_t中错误码的说明
```
（2）对某帧进行解码
```
vpx_codec_err_t vpx_codec_decode(vpx_codec_ctx_t *ctx, const uint8_t *data, unsigned int data_sz, void *user_priv, long deadline)
ctx：指向该解码器实例的指针
data：当前编码数据块的指针
data_sz：编码数据的大小
user_priv：与该帧关联的自定义数据，可为nullptr
deadline：解码器应尝试满足的在该帧上工作的时间（单位：微妙），如果不限制，则设为0
返回值：0解码成功，非0解码失败，参考vpx_codec_err_t中错误码的说明
```
（3）获取解码后图像
```
vpx_image_t *vpx_codec_get_frame(vpx_codec_ctx_t *ctx, vpx_codec_iter_t *iter)
ctx：指向该解码器实例的指针
iter：迭代器，首次使用应初始化为NULL
返回值：指向已解码帧的图像
```
（4）销毁解码器
```
vpx_codec_err_t vpx_codec_destroy(vpx_codec_ctx_t *ctx)
ctx：指向该解码器实例的指针
返回值：0销毁解码器成功，非0销毁解码器失败，参考vpx_codec_err_t中错误码的说明
```
## 功能支持说明
OpenHarmony目前仅集成了libvpx的解码能力，用于解析VP8和VP9的码流，暂不支持视频编码功能。
## License
详见仓库目录下的LICENSE文件
