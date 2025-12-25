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
（1）创建解码器
```
int vpx_create_decoder_api(void ** vpxDecoder, const char *name);
vpxDecoder:：解码器句柄
name：解码器的名称（vp8或vp9）
返回值：0创建解码器成功，1创建解码器失败
```
（2）对某帧进行解码
```
int vpx_codec_decode_api(void * vpxDecoder, const unsigned char *frame, unsigned int frame_size)
vpxDecoder：解码器句柄
frame：当前帧码流buffer
frame_size：当前帧码子大小
返回值：0解码成功，非0解码失败
```
（3）获取解码后图像
```
int vpx_codec_get_frame_api(void * vpxDecoder, vpx_image_t **outputImg) 
vpxDecoder：解码器句柄
outputmg：解码后图像
返回值：0
```
（4）销毁解码器
```
int vpx_destroy_decoder_api(void ** vpxDecoder)
vpxDecoder：解码器句柄
返回值：0销毁解码器成功，1销毁解码器失败
```
## 功能支持说明
OpenHarmony目前仅集成了libvpx的解码能力，用于解析vp8和vp9的码流，暂不支持视频编码功能。
## License
详见仓库目录下的LICENSE.md文件