import SwiftUI
import WidgetKit

@MainActor
final class RitualModel: ObservableObject {
    @Published var record = RitualStorage.read()
    func refresh() { record = RitualStorage.read() }
    func draw() {
        refresh()
        guard record.fortune == nil else { return }
        record.fortune = Int.random(in: DailyContent.fortunes.indices)
        save()
    }
    func offer() { refresh(); record.incense = true; save() }
    private func save() { RitualStorage.write(record); WidgetCenter.shared.reloadAllTimelines() }
}

@main
struct XuanXuApp: App {
    @StateObject private var model = RitualModel()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup { ContentView().environmentObject(model) }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
    }
}
