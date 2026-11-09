import Foundation
struct LexiconEntry: Decodable { let pinyin: String; let text: String; let weight: Int }
struct Candidate { let text: String; let score: Double }
struct ShuangpinScheme: Codable {
    var id: String; var name: String; var initials: [String: String]; var finals: [String: String]; var zeroRule: String; var zeroKey: String; var overrides: [String: [String]]?
    static func load() -> [ShuangpinScheme] { guard let url = Bundle.main.url(forResource: "schemes", withExtension: "json"), let data = try? Data(contentsOf: url) else { return [] }; return (try? JSONDecoder().decode([ShuangpinScheme].self, from: data)) ?? [] }
    func encode(_ pinyin: String) -> [String] {
        var result = [""]
        for piece in pinyin.split(whereSeparator: { $0 == " " || $0 == "'" }) {
            let s = String(piece); var codes: [String] = []
            if let explicit = overrides?[s] { codes = explicit } else {
                let initial = ["zh","ch","sh","b","p","m","f","d","t","n","l","g","k","h","j","q","x","r","z","c","s","y","w"].first(where: { s.hasPrefix($0) }) ?? ""
                guard let finalKey = finals[String(s.dropFirst(initial.count))] else { return [] }
                if !initial.isEmpty { guard let head = initials[initial] else { return [] }; codes = [head+finalKey] }
                else if zeroRule == "natural" { codes = [s.count == 2 ? s : String(s.prefix(1))+finalKey] }
                else if zeroRule == "first-letter" { codes = [String(s.prefix(1))+finalKey] }
                else { codes = [zeroKey+finalKey] }
            }
            result = Array(result.flatMap { a in codes.map { a+$0 } }.prefix(64))
        }; return result
    }
}
final class PinyinEngine {
    let entries: [LexiconEntry]
    private struct Record { let text: String; let pinyin: String; let key: String; let short: String; let weight: Int }
    private var records: [Record] = []; private var exact: [String: Record] = [:]
    static func normalize(_ s: String) -> String { s.lowercased().replacingOccurrences(of: "ü", with: "v").replacingOccurrences(of: "u:", with: "v").filter { $0.isASCII && (($0 >= "a" && $0 <= "z") || $0 == ";") } }
    init() { if let url = Bundle.main.url(forResource: "lexicon", withExtension: "json"), let data = try? Data(contentsOf: url), let decoded = try? JSONDecoder().decode([LexiconEntry].self, from: data) { entries = decoded } else { entries = [] }; setScheme(nil) }
    func setScheme(_ s: ShuangpinScheme?) {
        records = []; exact = [:]
        for e in entries { let codes = s?.encode(e.pinyin) ?? [Self.normalize(e.pinyin)]; let short = s == nil ? e.pinyin.split(separator: " ").compactMap { $0.first }.map(String.init).joined() : ""
            for code in codes { let r = Record(text: e.text, pinyin: e.pinyin, key: code, short: short, weight: e.weight); records.append(r); if r.weight > (exact[code]?.weight ?? -1) { exact[code] = r } }
        }
    }
    func lookup(_ raw: String, learned: [String: Int]) -> [Candidate] {
        let key = String(Self.normalize(raw).prefix(48)); guard !key.isEmpty else { return [] }; var found: [Candidate] = []
        for e in records { let rank = e.key == key ? 100000 : e.short == key ? 50000 : e.key.hasPrefix(key) ? 20000 : 0
            if rank > 0 { found.append(Candidate(text: e.text, score: Double(rank+e.weight-(e.key.count-key.count)*2+min(10000, learned[key+"|"+e.text] ?? 0)*10))) }
        }
        let chars = Array(key); var scores = Array(repeating: -Double.infinity, count: chars.count+1); var texts: [String?] = Array(repeating: nil, count: chars.count+1); var parts = Array(repeating: 0, count: chars.count+1); scores[0] = 0; texts[0] = ""
        for end in 1...chars.count { for start in 0..<end { if let e = exact[String(chars[start..<end])], let prefix = texts[start] { let score = scores[start]+pow(Double(end-start),2)+log1p(Double(e.weight))/10-2; if score > scores[end] { scores[end] = score; texts[end] = prefix+e.text; parts[end] = parts[start]+1 } } } }
        if parts[chars.count] > 1, let text = texts[chars.count] { found.append(Candidate(text: text, score: 80000+scores[chars.count])) }; var seen = Set<String>(); return Array(found.sorted { $0.score > $1.score }.filter { seen.insert($0.text).inserted }.prefix(60))
    }
}
