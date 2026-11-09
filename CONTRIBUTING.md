# 参与玖云输入法

欢迎修复双拼键位、完善词库、增加跨端测试和原生交互。

1. 使用 Node.js 20+。修改前运行 npm test。
2. 词条只修改 packages/lexicon/starter.json；双拼预设只修改 packages/core/shuangpin.mjs。
3. 修改共享数据后运行 npm run generate；不要只改某一端的生成文件。
4. 修改编码逻辑时补充已知输入输出用例，特别注意零声母、ü、zh/ch/sh、分号键和不同方案同码。
5. 提交前运行 npm test、npm run check 和 node scripts/generate.mjs --check。
6. 原生改动请注明实际测试的系统、构建工具和设备；没有运行的检查应明确标记未运行。

不要提交他人输入内容、个人词库、凭据、签名证书或许可不明的数据。贡献按项目 MIT 许可提供。请在问题报告里写清方案名、输入编码、期望词语和实际结果。
