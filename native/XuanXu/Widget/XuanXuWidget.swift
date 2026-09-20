import SwiftUI
import WidgetKit

struct DailyEntry: TimelineEntry {
    let date: Date
    let record: DailyRecord
    let shared: Bool

    var animationProgress: Double {
        guard let started = record.animationDate, record.animation != nil else { return 1 }
        return min(max(date.timeIntervalSince(started) / 1.8, 0), 1)
    }

    var animationElapsed: TimeInterval {
        guard let started = record.animationDate, record.animation != nil else { return .greatestFiniteMagnitude }
        return date.timeIntervalSince(started)
    }

    var isAnimating: Bool {
        record.animation != nil && animationElapsed < 1.8
    }

    var isShowingResult: Bool {
        record.animation != nil && animationElapsed >= 1.8 && animationElapsed < 2.8
    }
}

struct DailyProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyEntry {
        DailyEntry(date: .now, record: DailyRecord(date: DailyContent.dayKey()), shared: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> Void) {
        completion(entry(.now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let normalDates = [now] + (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: tomorrow) }
        var dates = normalDates

        // A widget interaction gets a short sequence of entries so WidgetKit
        // can animate the ritual in place instead of jumping straight to the
        // completed state. The animation itself stays within WidgetKit's
        // roughly two-second update window, followed by a brief result frame.
        let current = RitualStorage.read(widget: true)
        if let started = current.animationDate, started.addingTimeInterval(2.8) > now {
            dates.append(contentsOf: stride(from: 0.0, through: 2.8, by: 0.2).map {
                now.addingTimeInterval($0)
            })
        }

        let entries = dates.map(entry).sorted { $0.date < $1.date }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(_ date: Date) -> DailyEntry {
        DailyEntry(date: date, record: RitualStorage.read(on: date, widget: true), shared: true)
    }
}

struct DailyWidgetView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    let entry: DailyEntry
    private var reading: Reading { DailyContent.reading(on: entry.date) }
    private var showsRitualResult: Bool { entry.isShowingResult }
    private var widgetSurface: Color {
        colorScheme == .dark ? Color(red: 0.075, green: 0.10, blue: 0.13) : Color(red: 0.89, green: 0.92, blue: 0.87)
    }
    private var widgetAccent: Color {
        colorScheme == .dark ? Color(red: 0.96, green: 0.77, blue: 0.38) : Color(red: 0.42, green: 0.32, blue: 0.16)
    }

    var body: some View {
        Group {
            if family == .accessoryInline {
                Text("玄序 · \(reading.text.replacingOccurrences(of: "\n", with: ""))")
            } else if family == .accessoryRectangular {
                accessoryRectangularContent
            } else if family == .systemSmall {
                smallContent
            } else {
                mediumContent
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                widgetSurface
                if colorScheme == .light {
                    WidgetInkMountainBackground().opacity(0.72)
                }
            }
        }
        .widgetURL(URL(string: "xuanxu://home"))
    }

    @ViewBuilder
    private var accessoryRectangularContent: some View {
        HStack(spacing: 10) {
            Button(intent: DrawFortuneIntent()) {
                Label(entry.isAnimating && entry.record.animation == "fortune" ? "抽签中" : entry.isShowingResult && entry.record.animation == "fortune" ? "已抽签" : "抽签", systemImage: entry.isShowingResult && entry.record.animation == "fortune" ? "checkmark" : "sparkles")
            }.buttonStyle(.borderless)
            Button(intent: OfferIncenseIntent()) {
                Label(entry.isAnimating && entry.record.animation == "incense" ? "上香中" : entry.isShowingResult && entry.record.animation == "incense" ? "已上香" : "上香", systemImage: entry.isShowingResult && entry.record.animation == "incense" ? "checkmark" : "flame")
            }.buttonStyle(.borderless)
        }
        .font(.caption2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var smallContent: some View {
        if entry.isAnimating, let kind = entry.record.animation {
            VStack(spacing: 5) {
                WidgetRitualAnimation(kind: kind, progress: entry.animationProgress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Text(kind == "incense" ? "香入炉…" : "求签中…")
                    .font(.system(.caption, design: .serif)).foregroundStyle(.secondary)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.94)))
        } else if showsRitualResult {
            completedRitual(compact: true)
        } else {
            VStack(alignment: .leading, spacing: 7) {
                Text(reading.text).font(.system(.title3, design: .serif)).lineLimit(2).minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                actionButtons
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var mediumContent: some View {
        if entry.isAnimating, let kind = entry.record.animation {
            HStack(spacing: 8) {
                WidgetRitualAnimation(kind: kind, progress: entry.animationProgress).frame(width: 112)
                VStack(alignment: .leading, spacing: 5) {
                    Text(kind == "incense" ? "每日上香" : "每日抽签").font(.system(.headline, design: .serif))
                    Text(kind == "incense" ? "香入炉…" : "心签将至…").font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }.transition(.opacity.combined(with: .scale(scale: 0.94)))
        } else if showsRitualResult {
            completedRitual(compact: false)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("玄序").font(.caption)
                    Spacer()
                    Text(entry.date, format: .dateTime.month().day()).font(.caption2)
                }.foregroundStyle(.secondary)
                Text(reading.text).font(.system(.title2, design: .serif)).minimumScaleFactor(0.75).lineLimit(2)
                Text(reading.source).font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.7)
                actionButtons
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func completedRitual(compact: Bool) -> some View {
        if entry.record.animation == "incense" {
            VStack(alignment: .leading, spacing: compact ? 5 : 7) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: compact ? 22 : 25, weight: .medium))
                    .foregroundStyle(widgetAccent)
                Text("今日已上香")
                    .font(.system(compact ? .headline : .title3, design: .serif))
                Text("香入炉，心归静")
                    .font(.caption).foregroundStyle(.secondary)
                if !compact { actionButtons }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else if let index = entry.record.fortune, DailyContent.fortunes.indices.contains(index) {
            let fortune = DailyContent.fortunes[index]
            VStack(alignment: .leading, spacing: compact ? 4 : 6) {
                Text("今日心签")
                    .font(.caption).foregroundStyle(.secondary)
                Text(fortune.title)
                    .font(.system(compact ? .title3 : .title2, design: .serif))
                    .foregroundStyle(widgetAccent)
                Text(fortune.verse)
                    .font(.system(compact ? .caption : .subheadline, design: .serif))
                    .lineLimit(compact ? 2 : 1)
                if !compact { actionButtons }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        } else {
            normalReading
        }
    }

    private var normalReading: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(reading.text).font(.system(.title3, design: .serif)).lineLimit(2).minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            actionButtons
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var actionButtons: some View {
        if #available(iOS 17.0, *) {
            HStack(spacing: 10) {
                Button(intent: DrawFortuneIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: entry.shared && entry.record.fortune != nil ? "checkmark" : "sparkles")
                            .symbolEffect(.bounce, value: entry.record.fortune != nil)
                        Text(entry.shared && entry.record.fortune != nil ? "已抽签" : "抽签")
                    }
                }.buttonStyle(.borderless).invalidatableContent()
                Button(intent: OfferIncenseIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: entry.shared && entry.record.incense ? "checkmark" : "flame")
                            .symbolEffect(.bounce, value: entry.record.incense)
                        Text(entry.shared && entry.record.incense ? "已上香" : "上香")
                    }
                }.buttonStyle(.borderless).invalidatableContent()
            }.font(.caption)
        }
    }
}

private struct WidgetInkMountainBackground: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var far = Path()
            far.move(to: CGPoint(x: 0, y: h * 0.58))
            far.addLine(to: CGPoint(x: w * 0.20, y: h * 0.35))
            far.addLine(to: CGPoint(x: w * 0.42, y: h * 0.55))
            far.addLine(to: CGPoint(x: w * 0.63, y: h * 0.25))
            far.addLine(to: CGPoint(x: w, y: h * 0.54))
            far.addLine(to: CGPoint(x: w, y: h))
            far.addLine(to: CGPoint(x: 0, y: h))
            far.closeSubpath()
            context.fill(far, with: .color(Color(red: 0.47, green: 0.58, blue: 0.53).opacity(0.28)))

            var near = Path()
            near.move(to: CGPoint(x: 0, y: h * 0.78))
            near.addLine(to: CGPoint(x: w * 0.28, y: h * 0.48))
            near.addLine(to: CGPoint(x: w * 0.51, y: h * 0.73))
            near.addLine(to: CGPoint(x: w * 0.76, y: h * 0.46))
            near.addLine(to: CGPoint(x: w, y: h * 0.70))
            near.addLine(to: CGPoint(x: w, y: h))
            near.addLine(to: CGPoint(x: 0, y: h))
            near.closeSubpath()
            context.fill(near, with: .color(Color(red: 0.21, green: 0.35, blue: 0.33).opacity(0.48)))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.72, y: h * 0.10, width: 26, height: 26)), with: .color(Color(red: 0.78, green: 0.76, blue: 0.62).opacity(0.34)))
        }
        .allowsHitTesting(false)
    }
}

private struct WidgetRitualAnimation: View {
    let kind: String
    let progress: Double

    var body: some View {
        ZStack {
            if kind == "incense" { incenseAnimation } else { fortuneAnimation }
        }.animation(.easeInOut(duration: 0.35), value: progress)
    }

    private var fortuneAnimation: some View {
        ZStack(alignment: .bottom) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.42, green: 0.28, blue: 0.13))
                    .frame(width: 7, height: 48 + CGFloat(index % 2) * 8)
                    .rotationEffect(.degrees((progress < 0.72 ? -15 : 0) + Double(index - 2) * 3))
                    .offset(x: CGFloat(index - 2) * 10, y: progress < 0.72 ? CGFloat(1 - progress) * 25 : 0)
            }
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.53, green: 0.38, blue: 0.19)).frame(width: 72, height: 35)
                .overlay(Text("签").font(.system(.headline, design: .serif)).foregroundStyle(.white.opacity(0.85)))
                .offset(y: 28)
            Circle().fill(.orange.opacity(progress > 0.78 ? 0.9 : 0)).frame(width: 8, height: 8).blur(radius: 2).offset(y: -34)
        }
    }

    private var incenseAnimation: some View {
        ZStack {
            if progress > 0.62 {
                ForEach(0..<3) { index in
                    Capsule().fill(.gray.opacity(0.18)).frame(width: 4, height: 35).blur(radius: 3)
                        .rotationEffect(.degrees(Double(index * 12) - 12))
                        .offset(x: CGFloat(index - 1) * 8, y: -50 - CGFloat(progress - 0.62) * 35)
                }
            }
            Rectangle().fill(Color.brown).frame(width: 4, height: 76)
                .overlay(alignment: .top) { Circle().fill(.orange).frame(width: 6, height: 6).shadow(color: .orange, radius: 5) }
                .rotationEffect(.degrees(24 * (1 - progress)), anchor: .bottom)
                .offset(x: 26 * (1 - progress), y: -20 * (1 - progress))
            WidgetIncenseBowlShape()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.40, green: 0.47, blue: 0.36), Color(red: 0.55, green: 0.59, blue: 0.46), Color(red: 0.30, green: 0.37, blue: 0.29)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 100, height: 42)
                .overlay {
                    Text("静")
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Color(red: 0.83, green: 0.84, blue: 0.70).opacity(0.78))
                }
                .offset(y: 40)
            if progress > 0.72 {
                Ellipse()
                    .stroke(Color(red: 0.61, green: 0.67, blue: 0.50).opacity(0.55), lineWidth: 1)
                    .frame(width: 112, height: 30)
                    .scaleEffect(progress > 0.86 ? 1.12 : 0.78)
                    .opacity(progress > 0.86 ? 0.18 : 0.58)
                    .offset(y: 22)
            }
            Ellipse()
                .fill(Color(red: 0.22, green: 0.29, blue: 0.22))
                .frame(width: 88, height: 12)
                .overlay { Ellipse().stroke(Color(red: 0.68, green: 0.72, blue: 0.55).opacity(0.45), lineWidth: 1) }
                .offset(y: 20)
        }
        .frame(width: 124, height: 126)
    }
}

private struct WidgetIncenseBowlShape: Shape {
    func path(in rect: CGRect) -> Path {
        let left = rect.minX + 5
        let right = rect.maxX - 5
        let top = rect.minY + 2
        let bottom = rect.maxY
        let bottomLeft = rect.minX + 20
        let bottomRight = rect.maxX - 20
        var path = Path()
        path.move(to: CGPoint(x: left, y: top))
        path.addLine(to: CGPoint(x: right, y: top))
        path.addCurve(
            to: CGPoint(x: bottomRight, y: bottom),
            control1: CGPoint(x: right - 2, y: rect.midY - 2),
            control2: CGPoint(x: bottomRight + 8, y: bottom - 3)
        )
        path.addLine(to: CGPoint(x: bottomLeft, y: bottom))
        path.addCurve(
            to: CGPoint(x: left, y: top),
            control1: CGPoint(x: bottomLeft - 8, y: bottom - 3),
            control2: CGPoint(x: left + 2, y: rect.midY - 2)
        )
        path.closeSubpath()
        return path
    }
}

@main
struct XuanXuWidget: Widget {
    let kind = "XuanXuDaily"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyProvider()) { entry in DailyWidgetView(entry: entry) }
            .configurationDisplayName("玄序 · 每日课诵")
            .description("读一句经典，直接完成今日抽签与上香。")
            .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}
