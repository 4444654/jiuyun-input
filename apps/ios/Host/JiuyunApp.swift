import SwiftUI
@main struct JiuyunApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}
struct ContentView: View {
    @State private var draft = ""
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: "leaf.fill").font(.system(size: 45)).foregroundColor(Color(red: 0.31, green: 0.45, blue: 0.38))
                Text("玖云输入法").font(.largeTitle).bold()
                Text("让表达，自然发生。").font(.title3)
                Text("本地拼音 · MIT 开源 · 开发预览版").font(.subheadline).foregroundColor(.secondary)
                Text("1. 打开系统设置 → 通用 → 键盘 → 键盘。\n2. 添加新键盘，选择玖云输入法。\n3. 在任意输入框，通过地球按钮切换到玖云。")
                Text("无需开启「允许完全访问」。基础词库覆盖有限，适合学习与继续开发。").font(.footnote).foregroundColor(.secondary)
                TextEditor(text: $draft).frame(height: 150).padding(10).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3))).accessibilityLabel("试用玖云输入法")
            }.padding(28)
        }.background(Color(red: 0.97, green: 0.98, blue: 0.96))
    }
}
