import Foundation

struct Reading {
    let text: String
    let source: String
}

struct Fortune {
    let title: String
    let verse: String
    let reflection: String
}

struct Almanac {
    let yi: String
    let ji: String
}

private struct BundledAlmanac: Decodable {
    struct Entry: Decodable {
        let date: String
        let yi: String
        let ji: String
    }
    let entries: [Entry]
}

enum DailyContent {
    static let readings = [
        Reading(text: "常能遣其欲，\n而心自静。", source: "《太上老君说常清静经》"),
        Reading(text: "上善若水，\n水善利万物而不争。", source: "《道德经》第八章"),
        Reading(text: "致虚极，\n守静笃。", source: "《道德经》第十六章"),
        Reading(text: "人能常清静，\n天地悉皆归。", source: "《太上老君说常清静经》"),
        Reading(text: "澄其心，\n而神自清。", source: "《太上老君说常清静经》"),
        Reading(text: "知人者智，\n自知者明。", source: "《道德经》第三十三章"),
        Reading(text: "常应常静，\n常清静矣。", source: "《太上老君说常清静经》")
    ]
    static let fortunes = [
        Fortune(title: "守静", verse: "风过竹有声，风止竹还静。", reflection: "留一段不被打扰的时间。先安顿心绪，再回应眼前的事。"),
        Fortune(title: "知止", verse: "行至水穷处，停步看云生。", reflection: "今天不必把每件事都推向结果。辨清可做与不可做，留一点余地。"),
        Fortune(title: "日新", verse: "庭前一叶落，阶下又生青。", reflection: "整理一处小角落，放下一件旧烦恼。"),
        Fortune(title: "和光", verse: "月照千江水，清辉不问名。", reflection: "温和地表达，也清楚地守住自己的边界。"),
        Fortune(title: "徐行", verse: "山路随云转，清泉伴步长。", reflection: "选定一件值得做的事，慢慢把它做好。"),
        Fortune(title: "清简", verse: "一室容清风，半窗留月色。", reflection: "少一个多余的安排，多一点自在的空白。")
    ]
    static let almanacs = [
        Almanac(yi: "省心 · 沐浴", ji: "妄语 · 喧怒"),
        Almanac(yi: "读经 · 散步", ji: "贪多 · 争执"),
        Almanac(yi: "早起 · 静坐", ji: "急行 · 多言"),
        Almanac(yi: "整理 · 亲近自然", ji: "躁进 · 过劳"),
        Almanac(yi: "饮茶 · 观云", ji: "忧思 · 熬夜"),
        Almanac(yi: "行善 · 守静", ji: "喧哗 · 强求"),
        Almanac(yi: "留白 · 徐行", ji: "拖延 · 纷扰")
    ]

    private static let bundledAlmanac: [String: Almanac] = {
        guard let url = Bundle.main.url(forResource: "almanac-2026", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(BundledAlmanac.self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: payload.entries.map {
            ($0.date, Almanac(yi: $0.yi, ji: $0.ji))
        })
    }()

    static func dayKey(_ date: Date = Date()) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
    static func reading(on date: Date) -> Reading {
        return readings[stableIndex(for: dayKey(date), count: readings.count)]
    }
    static func almanac(on date: Date) -> Almanac {
        if let entry = bundledAlmanac[dayKey(date)] { return entry }
        return almanacs[stableIndex(for: dayKey(date), count: almanacs.count)]
    }

    private static func stableIndex(for key: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        var hash: UInt64 = 1469598103934665603
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return Int(hash % UInt64(count))
    }
}

struct DailyRecord: Codable {
    var date: String
    var fortune: Int?
    var incense = false
    // WidgetKit uses these fields to render a short ritual sequence after an
    // AppIntent completes. They are optional so records from older builds keep
    // decoding cleanly.
    var animation: String?
    var animationDate: Date?
}

enum RitualStorage {
    // App Groups can be enabled in both targets using Shared.xcconfig.
    static var sharedDefaults: UserDefaults? {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "RitualAppGroup") as? String,
              !group.isEmpty, !group.contains("$("),
              FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil else { return nil }
        return UserDefaults(suiteName: group)
    }
    static func read(on date: Date = Date(), widget: Bool = false) -> DailyRecord {
        let defaults = sharedDefaults ?? UserDefaults.standard
        guard let data = defaults.data(forKey: "daily.ritual"),
              var record = try? JSONDecoder().decode(DailyRecord.self, from: data),
              record.date == DailyContent.dayKey(date) else {
            return DailyRecord(date: DailyContent.dayKey(date))
        }
        if let index = record.fortune, !DailyContent.fortunes.indices.contains(index) { record.fortune = nil }
        return record
    }
    static func write(_ record: DailyRecord, widget: Bool = false) {
        guard let data = try? JSONEncoder().encode(record) else { return }
        (sharedDefaults ?? .standard).set(data, forKey: "daily.ritual")
    }
}
