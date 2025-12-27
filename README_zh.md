# libvpx
原始仓来源：https://github.com/webmproject/libvpx

仓库包含第三方开源软件libvpx，libvpx是vp8、vp9标准的视频编解码器。在OpenHarmony中，libvpx主要媒体子系统的基础组件，提供vp8、vp9码流的解码能力。
## 目录结构
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
## OpenHarmony如何使用libvpx
OpenHarmony的系统部件需要在BUILG.gn中引用libvpx部件以使用libppx。
```
// BUILD.gn
external_deps + = [libvpx:vpxdec_ohos]
```
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
vpx_codec_err_t vpx_codec_decode(vpx_codec_ctx_t *ctx, const uint8_t *data, unsigned int data_sz, void *user_priv, long deadline);
ctx：指向该解码器实例的指针
data：当前编码数据块的指针
data_sz：编码数据的大小
user_priv：与该帧关联的自定义数据，可为nullptr
deadline：解码器应尝试满足的软截止时间（单位：微妙），如果不限制，则设为0
返回值：0解码成功，非0解码失败，参考vpx_codec_err_t中错误码的说明
```
（3）获取解码后图像
```
vpx_image_t *vpx_codec_get_frame(vpx_codec_ctx_t *ctx, vpx_codec_iter_t *iter);
ctx：指向该解码器实例的指针
iter：迭代器，首次使用应初始化为NULL
返回值：指向已解码帧的图像
```
（4）销毁解码器
```
vpx_codec_err_t vpx_codec_destroy(vpx_codec_ctx_t *ctx);
ctx：指向该解码器实例的指针
返回值：0销毁解码器成功，非0销毁解码器失败，参考vpx_codec_err_t中错误码的说明
```
## 功能支持说明
OpenHarmony目前仅集成了libvpx的解码能力，用于解析vp8和vp9的码流，暂不支持视频编码功能。
## License
详见仓库目录下的LICENSE.md文件