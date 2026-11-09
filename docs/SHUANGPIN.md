# 双拼是玖云的主输入方式

默认小鹤双拼，支持 8 套内置方案和全拼。方案不是界面选项占位：每次切换都会重建候选索引，键入的编码按所选规则匹配基础词库。

| 方案 ID | 名称 | 你好 | 玖云 | 零声母主规则 |
| --- | --- | --- | --- | --- |
| flypy | 小鹤双拼 | nihc | jqyy | 两字母保留全拼，其余首字母 + 韵母键 |
| microsoft | 微软双拼 | nihk | jqyp | o + 韵母键 |
| ziranma | 自然码 | nihk | jqyp | 两字母保留全拼，其余首字母 + 韵母键 |
| sogou | 搜狗双拼 | nihk | jqyp | o + 韵母键 |
| abc | 智能 ABC | nihk | jryn | o + 韵母键 |
| ziguang | 紫光双拼 | nihq | jjym | o + 韵母键 |
| pyjj | 拼音加加 | nihd | jnyz | 首字母 + 韵母键 |
| gb | 国标双拼 | nihc | jyyz | a + 韵母键 |

微软与搜狗的 ing 使用分号键；微软的 ve 默认使用 v，搜狗使用 t。不同输入法可能提供额外兼容码。玖云采用文档列出的主码，不默认混用其他方案的零声母兼容码。可以用 overrides 明确添加兼容编码，例如微软 lve → lt。

## 修改方案

Web 进入「双拼方案」，从预设点击「自定义」。可修改所有普通声母、zh/ch/sh、所有韵母、零声母规则和固定前缀。修改后保存为个人方案，不改变内置数据。最多保存 32 套个人方案。

配置结构：

~~~json
{
  "id": "custom_example",
  "name": "我的小鹤",
  "initials": { "b": "b", "zh": "v", "ch": "i", "sh": "u" },
  "finals": { "a": "a", "ing": "k", "ao": "c" },
  "zeroRule": "natural",
  "zeroKey": "o",
  "overrides": { "ai": ["ai", "ad"] }
}
~~~

上面省略了大部分键位，仅用于解释结构。实际导入必须包含完整声母、韵母表；请从页面导出完整配置，再修改。单个映射值只能为一个小写字母或分号。一个键可以同时承载多种韵母，这是正常双拼规则。overrides 的值是 1–4 个两键编码，适合处理兼容码和特殊音节。

zeroRule 有三种：

- natural：两字母零声母音节保留原拼（ai、an、er）；其他使用首字母 + 韵母键（a → aa，ang → ah，按各方案映射）。
- prefix：固定 zeroKey + 韵母键（微软 a → oa，国标 a → aa）。
- first-letter：首字母 + 韵母键（拼音加加 ai → as）。

y、w 按书写声母处理，ü 以 v 表示。当前不支持模糊音和声调码。零声母与分号键有专门测试。

## 各端共用方式

- packages/core/shuangpin.mjs 是方案定义和编码算法的源文件；npm run generate 导出 schemes.json 给移动端，并生成 Rime 双拼编码词典。
- Web：完整方案编辑、导入导出、逐音节覆盖；自定义个人词条也参与双拼编码。
- Android：选择预设或编辑完整 JSON，保存后下一次打开键盘生效；读取同一 app 私有配置，不需要网络。
- iOS：键盘内「方案」选择预设，「设置」编辑声母、韵母和零声母规则。个人方案存在键盘扩展自己的 UserDefaults。当前不提供主 App 与扩展间的云同步或 JSON 文件导入。
- 桌面：使用导出的 JSON 运行 node scripts/generate.mjs --scheme 路径，再把生成的 jiuyun_custom 两个文件交给 Rime。内置方案直接使用已生成文件。

## 公开规则参考

项目按键位与零声母规则事实独立实现，未复制以下项目的实现代码或完整方案文件。

- [Rime 小鹤方案](https://github.com/rime/rime-double-pinyin/blob/master/double_pinyin_flypy.schema.yaml)
- [Rime 微软方案](https://github.com/rime/rime-double-pinyin/blob/master/double_pinyin_mspy.schema.yaml)
- [Rime 自然码方案](https://github.com/rime/rime-double-pinyin/blob/master/double_pinyin.schema.yaml)
- [Rime 智能 ABC 方案](https://github.com/rime/rime-double-pinyin/blob/master/double_pinyin_abc.schema.yaml)
- [Rime 拼音加加方案](https://github.com/rime/rime-double-pinyin/blob/master/double_pinyin_pyjj.schema.yaml)
- [libime 的紫光、国标等键位资料](https://github.com/fcitx/libime/blob/master/src/libime/pinyin/shuangpindata.h)
- [搜狗官方双拼说明](https://shouji.sogou.com/bangzhu.php?cid=99&pid=5)

这些外部项目仍适用它们自己的许可证。测试中保存了各方案的已知编码向量，修改映射时需要一起核对。
