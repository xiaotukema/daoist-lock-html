import AppIntents
import Foundation
import WidgetKit

/// The two widget actions write to the shared store when an App Group is
/// available, and otherwise use the extension's local store. WidgetKit
/// reloads the timeline after an AppIntent completes, so the button can show
/// the ritual in place instead of opening the app and breaking the flow.
struct DrawFortuneIntent: AppIntent {
    static var title: LocalizedStringResource = "每日抽签"
    static var description = IntentDescription("在组件上抽取今日心签")
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        var record = RitualStorage.read(widget: true)
        if record.fortune == nil {
            record.fortune = Int.random(in: DailyContent.fortunes.indices)
        }
        record.animation = "fortune"
        record.animationDate = Date()
        RitualStorage.write(record, widget: true)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct OfferIncenseIntent: AppIntent {
    static var title: LocalizedStringResource = "每日上香"
    static var description = IntentDescription("在组件上完成今日上香")
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        var record = RitualStorage.read(widget: true)
        record.incense = true
        record.animation = "incense"
        record.animationDate = Date()
        RitualStorage.write(record, widget: true)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
