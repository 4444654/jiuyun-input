# 独立 Windows 输入法

此目录直接使用 Windows Text Services Framework，**不依赖 Rime 或小狼毫**。系统接入基于微软 MIT 许可的 SampleIME 改造，保留原版权与许可证。玖云使用自己的 COM GUID、产品名称、候选配色、基础词库与方案配置。

使用 Visual Studio 2022 C++ 工具、Windows 10/11 SDK、CMake 和 Inno Setup 6 构建：

~~~powershell
node scripts/generate-native.mjs
cmake -S apps/windows -B apps/windows/build/x64 -A x64
cmake --build apps/windows/build/x64 --config Release
cmake -S apps/windows -B apps/windows/build/x86 -A Win32
cmake --build apps/windows/build/x86 --config Release
iscc apps/windows/installer.iss
~~~

安装器包含 64 位及 32 位输入服务、独立设置程序与 8 套双拼 / 全拼词典。安装后在 Win + 空格菜单选择「玖云输入法」。设置程序保存所选方案；空组字时自动加载配置。自定义方案可在网页版编辑，并导出 Windows 词典，再在玖云设置程序中导入。

安装器会在系统里注册玖云输入服务，卸载器会注销它。不要把未经过编译和运行验证的源码称为可用安装包。当前基础词库覆盖有限，不含统计语言模型。安装器尚未进行商业证书签名。

上游：[microsoft/Windows-classic-samples, Samples/IME/cpp/SampleIME](https://github.com/microsoft/Windows-classic-samples/tree/main/Samples/IME/cpp/SampleIME)。源码来自本次取得的上游版本；微软版权保留在 tsf/ 下。玖云修改包括标识、词典、方案切换、分号键与安装流程。
