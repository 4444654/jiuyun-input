# 多端构建与系统接入

Windows 主方案为独立 TSF 系统输入法，不需要小狼毫。安装包由 GitHub Actions 构建，是否可下载以 Releases 实际附件为准。当前没有商业代码签名；不同系统与应用的输入兼容性仍需实机验收。

## Web / PWA

Node.js 20+，在项目根目录 npm start，然后访问 http://127.0.0.1:4317。无运行时 npm 依赖。可用 PORT 环境变量改端口。服务默认只绑定 127.0.0.1。要在其他设备访问，需自行配置局域网服务及 HTTPS；远程纯 HTTP 不保证离线缓存或剪贴板 API 可用。

输入体验：

- 默认小鹤：nihc → 你好，jqyy → 玖云。方案下拉菜单可切换其余七种双拼或全拼。
- 空格选择高亮候选；数字键 1–9 选择当前页候选；减号与等号翻页；上下键移动候选。
- 单按 Shift 切换中英文，Esc 取消组字，Enter 提交原始编码。Ctrl/Command + Z 撤销。
- 「双拼方案」可自定义并导出 JSON；「词库管理」保存的词条按全拼音节添加，然后自动转成各方案的双拼码。

Web 是页面内体验，不会接管其他应用的输入。

## Windows：独立系统输入法

安装 GitHub Releases 实际发布的 Windows Setup.exe。包内包含 64/32 位输入服务、玖云设置程序、8 套双拼与全拼词典。安装后使用 Win + 空格选择「玖云输入法」。设置里选择方案；在网页「双拼方案」编辑后可导出 Windows 词典，再由设置程序导入。

构建说明见 [apps/windows/README.md](../apps/windows/README.md)。该实现改造自微软 MIT 开源 SampleIME，直接接入 Windows TSF，与 Rime 没有运行时依赖。

## 可选 Rime 兼容适配：Windows / macOS / Linux

使用 Rime 作为宿主输入法。不需要第三方大词库，项目附带完整基础词典文件。

1. 安装对应宿主：Windows [小狼毫](https://github.com/rime/weasel)，macOS [鼠须管](https://github.com/rime/squirrel)，Linux [IBus Rime](https://github.com/rime/ibus-rime) 或 [Fcitx5 Rime](https://github.com/fcitx/fcitx5-rime)。
2. 在宿主菜单中打开用户数据目录。典型位置：Windows 为小狼毫菜单的「用户文件夹」；macOS 为 ~/Library/Rime；IBus 为 ~/.config/ibus/rime；Fcitx5 为 ~/.local/share/fcitx5/rime。以宿主实际路径为准。
3. 将 adapters/rime 下需要的 .schema.yaml 和 .dict.yaml 成对复制进去。小鹤为 jiuyun_flypy，微软为 jiuyun_microsoft，其余名称见下表。
4. 备份已有 default.custom.yaml，在其已有 patch 下添加方案。不要用示例覆盖已有个性配置。只有新增小鹤时，可合并示例中的 schema_list/@next 规则。
5. 需要多个方案时，在现有 schema_list 中保留已有项并加入：

~~~yaml
patch:
  schema_list:
    - schema: jiuyun_flypy
    - schema: jiuyun_microsoft
    - schema: jiuyun_ziranma
    - schema: jiuyun_sogou
    - schema: jiuyun_abc
    - schema: jiuyun_ziguang
    - schema: jiuyun_pyjj
    - schema: jiuyun_gb
    - schema: jiuyun
~~~

6. Windows 按需合并 weasel.custom.example.yaml 的配色项到 weasel.custom.yaml；macOS 合并 squirrel.custom.example.yaml 到 squirrel.custom.yaml。Linux 候选栏外观由 IBus/Fcitx5 宿主主题控制。
7. 执行宿主的「重新部署」，用方案切换菜单选「玖云 · 小鹤双拼」等方案。

| 标识 | 方案 |
| --- | --- |
| jiuyun_flypy | 小鹤 |
| jiuyun_microsoft | 微软 |
| jiuyun_ziranma | 自然码 |
| jiuyun_sogou | 搜狗 |
| jiuyun_abc | 智能 ABC |
| jiuyun_ziguang | 紫光 |
| jiuyun_pyjj | 拼音加加 |
| jiuyun_gb | 国标 |
| jiuyun | 全拼 |

双拼方案使用由共享映射生成的编码表；全拼使用 Rime 的 script_translator。桌面分句和排序由 Rime 执行，与 Web/移动端的简化引擎不保证完全相同。双拼动态造词仍需实际部署验证。扩充基础词库后应重新运行 npm run generate。

自定义：从 Web 导出完整 JSON，运行 node scripts/generate.mjs --scheme 文件路径，再部署生成的 jiuyun_custom 两个文件并加入方案列表。

## Android

工具链：Android Studio 或 Gradle 8.9，JDK 17，Android SDK 35；最低 Android 8.0 / API 26。项目固定 Android Gradle Plugin 8.7.3。没有将 Gradle Wrapper 二进制打包进源码。

~~~sh
cd apps/android
gradle :app:assembleDebug
~~~

产物为 app/build/outputs/apk/debug/app-debug.apk。安装到测试设备，打开「玖云输入法」App，依次启用并切换输入法。

App 里选择 8 套预设或全拼。自定义区域可粘贴 Web 导出的完整方案 JSON，编辑后点「保存并启用」，下次打开键盘生效。自定义方案不上传。键盘有数字/符号页、中英切换、候选翻页和输入法切换入口。

密码和标记为不允许个性学习的字段不会学习词频；数字和电话字段默认使用英文数字符号。未提供 Android 原生主题编辑、个人词库界面、语音或手写。清单没有申请 INTERNET 权限。

## iOS / iPadOS

需要 macOS、Xcode 和 [XcodeGen](https://github.com/yonaskolb/XcodeGen)。

~~~sh
cd apps/ios
xcodegen generate
open Jiuyun.xcodeproj
~~~

工程包括 Jiuyun 引导 App 和 JiuyunKeyboard 扩展。为两个 target 设置自己的开发团队和 Bundle ID。选择 Jiuyun scheme 编译至设备。系统设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → 玖云。

键盘「方案」入口可选 8 套双拼或全拼；「设置」可逐项修改声母、韵母、零声母规则和前缀，保存为一个个人方案。这里的配置存在扩展私有容器，不依赖主 App 共享存储或完全访问权限。

不申请完全访问。系统安全输入框等场景会使用系统键盘，部分 App 也会限制第三方键盘。当前 iOS 没有主 App 到键盘的 JSON 文件导入、云同步、语音或手写。

## 官方实现参考

- [Android 创建输入法](https://developer.android.com/develop/ui/views/touch-and-input/creating-input-method)
- [Android Gradle Plugin 8.7 兼容要求](https://developer.android.com/build/releases/agp-8-7-0-release-notes)
- [Apple 创建自定义键盘](https://developer.apple.com/documentation/UIKit/creating-a-custom-keyboard)
- [Rime 输入方案设计](https://github.com/rime/home/wiki/RimeWithSchemata)
- [小狼毫定制说明](https://github.com/rime/weasel/wiki/Weasel-%E5%AE%9A%E5%88%B6%E5%8C%96)
