import UIKit
final class KeyboardViewController: UIInputViewController {
    private let engine = PinyinEngine()
    private var schemes = ShuangpinScheme.load()
    private var scheme: ShuangpinScheme?
    private var buffer = "", english = false, symbols = false, page = 0
    private var learned: [String: Int] = [:]
    private let column = UIStackView(), candidateRow = UIStackView(), keyColumn = UIStackView()
    private let composing = UILabel()
    private let green = UIColor(red: 0.31, green: 0.45, blue: 0.38, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        scheme = schemes.first
        let savedID = UserDefaults.standard.string(forKey: "jiuyun_scheme")
        if savedID == "full" { scheme = nil } else if savedID == "custom", let data = UserDefaults.standard.data(forKey: "jiuyun_custom"), let saved = try? JSONDecoder().decode(ShuangpinScheme.self, from: data) { scheme = saved } else if let s = schemes.first(where: { $0.id == savedID }) { scheme = s }
        engine.setScheme(scheme)
        learned = UserDefaults.standard.dictionary(forKey: "jiuyun_frequency") as? [String: Int] ?? [:]
        view.backgroundColor = UIColor(red: 0.91, green: 0.93, blue: 0.91, alpha: 1)
        column.axis = .vertical; column.spacing = 5; column.translatesAutoresizingMaskIntoConstraints = false
        composing.font = .systemFont(ofSize: 12); composing.textColor = green
        candidateRow.axis = .horizontal; candidateRow.spacing = 5; candidateRow.distribution = .fillEqually
        keyColumn.axis = .vertical; keyColumn.spacing = 6
        view.addSubview(column); column.addArrangedSubview(composing); column.addArrangedSubview(candidateRow); column.addArrangedSubview(keyColumn)
        let height = view.heightAnchor.constraint(equalToConstant: 292); height.priority = .defaultHigh
        NSLayoutConstraint.activate([column.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6), column.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6), column.topAnchor.constraint(equalTo: view.topAnchor, constant: 8), column.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6), candidateRow.heightAnchor.constraint(equalToConstant: 40), height])
        drawKeys(); refresh()
    }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); buffer = ""; page = 0; refresh() }
    override func textDidChange(_ textInput: UITextInput?) { super.textDidChange(textInput); buffer = ""; page = 0; refresh() }
    private func button(_ title: String) -> UIButton {
        let b = UIButton(type: .system); b.setTitle(title, for: .normal); b.setTitleColor(.label, for: .normal); b.titleLabel?.font = .systemFont(ofSize: 17)
        b.backgroundColor = .secondarySystemBackground; b.layer.cornerRadius = 5; b.heightAnchor.constraint(greaterThanOrEqualToConstant: 36).isActive = true
        b.setContentCompressionResistancePriority(.defaultLow, for: .horizontal); return b
    }
    private func clear(_ stack: UIStackView) { for v in stack.arrangedSubviews { stack.removeArrangedSubview(v); v.removeFromSuperview() } }
    private func refresh() {
        guard isViewLoaded else { return }; composing.text = engine.entries.isEmpty ? "词库加载失败" : buffer.isEmpty ? "玖云 · "+(english ? "English" : scheme?.name ?? "全拼") : buffer
        clear(candidateRow); let cs = engine.lookup(buffer, learned: learned); page = min(page, max(0, (cs.count-1)/5))
        for c in cs.dropFirst(page*5).prefix(5) { let b = button(c.text); b.setTitleColor(green, for: .normal); b.addAction(UIAction { [weak self] _ in self?.commit(c.text) }, for: .touchUpInside); candidateRow.addArrangedSubview(b) }
        if cs.count > 5 { let b = button("›"); b.accessibilityLabel = "下一页候选"; b.addAction(UIAction { [weak self] _ in guard let self = self else { return }; self.page = (self.page+1) % ((cs.count+4)/5); self.refresh() }, for: .touchUpInside); candidateRow.addArrangedSubview(b) }
    }
    private func drawKeys() {
        clear(keyColumn)
        let rows: [[String]] = symbols ? [Array("1234567890").map(String.init), Array("@#$%&-+()").map(String.init), ["ABC","!","?",":",";","/","⌫"], ["方案","中/英","空格",";","↵","设置"]] : [Array("qwertyuiop").map(String.init), Array("asdfghjkl;").map(String.init), ["123"]+Array("zxcvbnm").map(String.init)+["⌫"], ["方案","中/英","空格",";","↵","设置"]]
        for (index, row) in rows.enumerated() {
            let line = UIStackView(); line.axis = .horizontal; line.spacing = 5; line.distribution = .fillEqually
            if index == rows.count-1 && needsInputModeSwitchKey { let globe = button("◎"); globe.accessibilityLabel = "切换键盘"; globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents); line.addArrangedSubview(globe) }
            for key in row { let b = button(key == "空格" ? (english ? "English" : "玖云") : key)
                if key == "↵" { b.backgroundColor = green; b.setTitleColor(.white, for: .normal) }
                b.addAction(UIAction { [weak self] _ in self?.key(key) }, for: .touchUpInside); line.addArrangedSubview(b)
            }; keyColumn.addArrangedSubview(line)
        }
    }
    private func applyScheme(_ s: ShuangpinScheme?) {
        buffer = ""; page = 0; scheme = s; engine.setScheme(s); UserDefaults.standard.set(s?.id ?? "full", forKey: "jiuyun_scheme"); drawKeys(); refresh()
    }
    private func showSchemePicker() {
        clear(keyColumn)
        let scroll = UIScrollView(); let list = UIStackView(); list.axis = .vertical; list.spacing = 5; list.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(list)
        NSLayoutConstraint.activate([list.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), list.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor), list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor), list.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)])
        for s in schemes { let b = button(s.name); b.addAction(UIAction { [weak self] _ in self?.applyScheme(s) }, for: .touchUpInside); list.addArrangedSubview(b) }
        if let data = UserDefaults.standard.data(forKey: "jiuyun_custom"), let custom = try? JSONDecoder().decode(ShuangpinScheme.self, from: data) { let b = button(custom.name); b.addAction(UIAction { [weak self] _ in self?.applyScheme(custom) }, for: .touchUpInside); list.addArrangedSubview(b) }
        let full = button("全拼输入"); full.addAction(UIAction { [weak self] _ in self?.applyScheme(nil) }, for: .touchUpInside); list.addArrangedSubview(full); keyColumn.addArrangedSubview(scroll)
    }
    private func showCustomization() {
        clear(keyColumn); var draft = scheme ?? schemes.first
        guard draft != nil else { drawKeys(); return }
        let scroll = UIScrollView(); let list = UIStackView(); list.axis = .vertical; list.spacing = 5; list.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(list)
        NSLayoutConstraint.activate([list.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), list.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor), list.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), list.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor), list.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)])
        let done = button("保存为自定义方案 · 返回键盘")
        done.addAction(UIAction { [weak self] _ in guard let self = self, var saved = draft else { return }; saved.id = "custom"; saved.name = "我的双拼"; if let data = try? JSONEncoder().encode(saved) { UserDefaults.standard.set(data, forKey: "jiuyun_custom") }; self.applyScheme(saved) }, for: .touchUpInside); list.addArrangedSubview(done)
        let cancel = button("取消修改"); cancel.addAction(UIAction { [weak self] _ in self?.drawKeys(); self?.refresh() }, for: .touchUpInside); list.addArrangedSubview(cancel)
        for group in ["initials", "finals"] {
            let map = group == "initials" ? draft!.initials : draft!.finals
            for sound in map.keys.sorted() { let b = button((group == "initials" ? "声母 " : "韵母 ")+sound+" → "+map[sound]!); b.showsMenuAsPrimaryAction = true
                b.menu = UIMenu(children: Array("abcdefghijklmnopqrstuvwxyz;").map { char in let key = String(char); return UIAction(title: key) { _ in if group == "initials" { draft?.initials[sound] = key } else { draft?.finals[sound] = key }; b.setTitle(sound+" → "+key, for: .normal) } }); list.addArrangedSubview(b)
            }
        }
        let zero = button("零声母规则："+draft!.zeroRule); zero.showsMenuAsPrimaryAction = true; zero.menu = UIMenu(children: ["natural","prefix","first-letter"].map { rule in UIAction(title: rule) { _ in draft?.zeroRule = rule; zero.setTitle("零声母规则："+rule, for: .normal) } }); list.addArrangedSubview(zero)
        let prefix = button("零声母前缀："+draft!.zeroKey); prefix.showsMenuAsPrimaryAction = true; prefix.menu = UIMenu(children: Array("abcdefghijklmnopqrstuvwxyz").map { char in let key = String(char); return UIAction(title: key) { _ in draft?.zeroKey = key; prefix.setTitle("零声母前缀："+key, for: .normal) } }); list.addArrangedSubview(prefix); keyColumn.addArrangedSubview(scroll)
    }
    private func commit(_ text: String, learn: Bool = true) {
        if !buffer.isEmpty && learn { let k = PinyinEngine.normalize(buffer)+"|"+text; learned[k] = min(10000, (learned[k] ?? 0)+10); UserDefaults.standard.set(learned, forKey: "jiuyun_frequency") }
        textDocumentProxy.insertText(text); buffer = ""; page = 0; refresh()
    }
    private func flush() { if !buffer.isEmpty { commit(buffer, learn: false) } }
    private func key(_ k: String) {
        if k == "方案" { showSchemePicker(); return }
        if k == "设置" { showCustomization(); return }
        if k == "中/英" { flush(); english.toggle(); drawKeys(); refresh(); return }
        if k == "123" || k == "ABC" { flush(); symbols.toggle(); drawKeys(); refresh(); return }
        if k == "⌫" { if buffer.isEmpty { textDocumentProxy.deleteBackward() } else { buffer.removeLast(); page = 0; refresh() }; return }
        if k == "空格" { if buffer.isEmpty { textDocumentProxy.insertText(" ") } else { let cs = engine.lookup(buffer, learned: learned); commit(cs.isEmpty ? buffer : cs[min(page*5,cs.count-1)].text, learn: !cs.isEmpty) }; return }
        if k == "↵" { if buffer.isEmpty { textDocumentProxy.insertText("\n") } else { flush() }; return }
        if !english && k.count == 1 && k.first!.isASCII && ((k.first! >= "a" && k.first! <= "z") || (k == ";" && scheme != nil)) { if buffer.count < 48 { buffer += k }; page = 0; refresh(); return }
        if !buffer.isEmpty { let cs = engine.lookup(buffer, learned: learned); commit(cs.isEmpty ? buffer : cs[min(page*5,cs.count-1)].text, learn: !cs.isEmpty) }
        let punctuation = [",":"，", ".":"。", "?":"？", "!":"！"]
        textDocumentProxy.insertText(english ? k : punctuation[k] ?? k)
    }
}
