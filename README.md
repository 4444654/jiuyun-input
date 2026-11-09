# 玖云输入法 · Jiuyun Input

**双拼优先，一字两键。** 一个以双拼为主打、在设备本地计算候选的多端开源输入法原型。

内置 **小鹤、微软、自然码、搜狗、智能 ABC、紫光、拼音加加、国标** 8 种双拼。默认使用小鹤，保留全拼模式。每种方案都可以作为自定义方案的起点。

## 立即运行

需要 Node.js 20 或更新版本。运行体验版不需要安装任何 npm 依赖。

~~~sh
npm start
~~~

打开 **http://127.0.0.1:4317**。Windows 也可以双击根目录的 **启动玖云.cmd**，再打开上面的地址。首次访问后，Web 版通过 Service Worker 缓存资源，支持离线使用。

默认小鹤：输入 **nihc** → 你好，**jqyy** → 玖云，**uurufa** → 输入法。

~~~sh
npm test                # 拼音、八套双拼与本地服务的 37 项测试
npm run check          # JavaScript 语法检查
npm run generate       # 生成各端词库和桌面方案
node scripts/generate.mjs --check  # 检查生成文件是否同步
~~~

## 已实现

- Web / PWA：实体键盘与触屏键盘、双拼和全拼切换、候选选词与翻页、基础词典整句组合、中英文切换、中文标点、撤销、复制。
- 双拼：8 套预设，键盘显示韵母提示；声母、韵母、零声母规则和固定前缀可修改；个人方案保存在本地，支持 JSON 导入导出。
- 个人词库：添加、搜索、删除、导入导出；词频在当前设备本地学习。
- 外观：浅草、夜色、纸笺三种主题，字号、候选数量可调。
- Windows：独立 TSF 系统输入法、设置程序和安装卸载器，包含 32/64 位输入服务，不要求小狼毫。
- macOS / Linux：当前保留可选 Rime 适配；独立原生接入尚未完成。
- Android：原生 InputMethodService 工程、8 套双拼和全拼选择、自定义方案 JSON、应用内启用引导、密码和数字字段处理。
- iOS / iPadOS：原生键盘扩展和引导 App、8 套双拼选择、键盘内自定义声韵母键位，不要求完全访问权限。

## 当前完成度

| 平台 | 交付内容 | 当前验证 |
| --- | --- | --- |
| Web / PWA | 可运行体验版 | 31 项核心、2 项原生词典、4 项服务测试；浏览器选词、方案、主题与键位编辑预览已验证 |
| Windows | 独立原生 TSF 输入法与 Setup 安装器工程 | 32/64 位服务与安装器云端编译通过；系统运行待验证 |
| macOS | Rime 鼠须管方案与配色 | 文件已生成；尚未安装部署验证 |
| Linux | Rime 方案 | 文件已生成；尚未安装部署验证 |
| Android | Java 原生系统输入法工程 | 按用户要求暂缓构建 |
| iOS / iPadOS | Swift 键盘扩展 + XcodeGen 工程定义 | iOS 模拟器编译通过；真机签名与运行待验证 |

此版本是 **v0.1.0 开发原型**。452 条原创基础词条用于验证输入流程，覆盖远小于日常成熟输入法；词典组合不是统计语言模型。还没有成熟纠错、大词库、语音、手写、九宫格、跨设备同步或签名安装包。浏览器演示只能在页面里输入；系统级输入由各平台原生接入实现。Windows 主方案不需要小狼毫；Rime 配置作为可选兼容适配保留。

## 自定义双拼

网页左侧进入「双拼方案」，从任一内置方案点「自定义」，修改后保存并启用。导出的 JSON 同时可用于桌面生成和 Android 配置。

~~~sh
node scripts/generate.mjs --scheme /path/to/my-layout.json
~~~

会额外生成 adapters/rime/jiuyun_custom.schema.yaml 和对应词典。完整配置结构、零声母规则和各端差异见 [双拼方案](docs/SHUANGPIN.md)。

## 项目结构

~~~text
apps/web/                 Web / PWA 体验界面（原生 ES Modules）
apps/windows/             独立 Windows TSF 输入法、设置和安装器
apps/android/             Android 原生系统输入法（Java）
apps/ios/                 iOS 键盘扩展、引导 App 与工程定义（Swift）
packages/core/            拼音候选、分句与双拼编码逻辑
packages/lexicon/         原创基础词库，唯一词库数据源
packages/schemes/         自动生成的八套双拼配置 JSON
adapters/rime/            桌面全拼、八套双拼和配色示例
scripts/                  本地服务、语法检查、跨端数据生成
tests/                    核心行为测试
.github/workflows/        核心检查、Windows 安装器和原生端构建流程
~~~

阅读 [多端构建与安装](docs/PLATFORMS.md)、[架构说明](docs/ARCHITECTURE.md)、[贡献指南](CONTRIBUTING.md)、[路线图](docs/ROADMAP.md)。

## 隐私与许可

输入候选在设备上计算。Web 版没有外部字体、分析脚本或账户系统；正文只存于页面内存。个人词条、词频和设置保存在本机浏览器。Android 不申请网络权限；iOS 键盘不申请完全访问权限。

项目原创代码、图形和基础词库采用 [MIT License](LICENSE)。Windows 接入改造自微软 MIT SampleIME，许可与来源见 [第三方说明](THIRD_PARTY_NOTICES.md)。键位表按公开输入规则独立实现，来源与差异记录在 [方案文档](docs/SHUANGPIN.md)。Rime 等外部软件的许可各自独立，本项目没有打包它们的二进制或第三方大词库。

本项目独立开发，与微信、腾讯及各方案对应厂商没有关联，不包含其代码、Logo 或专有素材。GitHub：[4444654/jiuyun-input](https://github.com/4444654/jiuyun-input)。独立 Windows 安装器由 GitHub Actions 构建；Android 暂缓打包，下载以 [Releases](https://github.com/4444654/jiuyun-input/releases) 实际附件为准。尚未提交应用商店。
