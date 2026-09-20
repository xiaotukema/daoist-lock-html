import SwiftUI

private enum Ritual: String, Identifiable {
    case fortune, incense
    var id: String { rawValue }
}

struct ContentView: View {
    @EnvironmentObject private var model: RitualModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @State private var ritual: Ritual?
    private var ink: Color { colorScheme == .dark ? Color(red: 0.94, green: 0.95, blue: 0.91) : Color(red: 0.20, green: 0.25, blue: 0.22) }
    private var mutedInk: Color { colorScheme == .dark ? Color(red: 0.72, green: 0.79, blue: 0.75) : Color(red: 0.38, green: 0.45, blue: 0.40) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.94, green: 0.77, blue: 0.38) : Color(red: 0.48, green: 0.34, blue: 0.13) }
    private var pageBackground: LinearGradient {
        colorScheme == .dark
            ? LinearGradient(colors: [Color(red: 0.035, green: 0.07, blue: 0.09), Color(red: 0.075, green: 0.12, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(red: 0.88, green: 0.91, blue: 0.86), Color(red: 0.72, green: 0.80, blue: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let reading = DailyContent.reading(on: context.date)
            let almanac = DailyContent.almanac(on: context.date)
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("玄序").font(.system(size: 23, weight: .medium, design: .serif))
                            Spacer()
                            Text(context.date, format: .dateTime.year().month().day())
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(mutedInk)
                        }
                        HStack(spacing: 0) {
                            Text("宜").foregroundStyle(accent)
                            Text("  \(almanac.yi)")
                            Rectangle().fill(mutedInk.opacity(0.35)).frame(width: 1, height: 14).padding(.horizontal, 12)
                            Text("忌").foregroundStyle(mutedInk)
                            Text("  \(almanac.ji)")
                        }
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(mutedInk)
                        .padding(.top, 10)
                        Text("今日课诵")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .tracking(4)
                            .foregroundStyle(accent)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 12)
                            .background(accent.opacity(colorScheme == .dark ? 0.16 : 0.12), in: Capsule())
                            .padding(.top, 10)
                        Text(reading.text)
                            .font(.system(size: 40, weight: .regular, design: .serif))
                            .lineSpacing(10)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 16)
                        Text(reading.source).font(.caption2).foregroundStyle(mutedInk)
                        HStack(spacing: 10) {
                            ritualButton("每日抽签", symbol: "sparkles", status: model.record.fortune == nil ? "静心 · 求一签" : "已抽签 · 重读", kind: .fortune)
                            ritualButton("每日上香", symbol: "flame", status: model.record.incense ? "已上香 · 静坐" : "一炷 · 寄心愿", kind: .incense)
                        }
                        .padding(.top, 14)
                    }
                    .padding(28)
                    .frame(maxWidth: 600, minHeight: max(proxy.size.height - 12, 0), alignment: .center)
                }
            }
            .onChange(of: DailyContent.dayKey(context.date)) { _, _ in model.refresh() }
        }
        .foregroundStyle(ink)
        .background {
            ZStack {
                pageBackground
                if colorScheme == .light {
                    InkMountainBackground().opacity(0.82)
                }
            }.ignoresSafeArea()
        }
        .sheet(item: $ritual) { choice in
            ritualSheet(for: choice)
        }
        .onChange(of: scenePhase) { _, phase in if phase == .active { model.refresh() } }
        .onOpenURL { url in
            model.refresh()
            if url.host == "incense" { ritual = .incense }
            else if url.host == "fortune" { ritual = .fortune }
        }
    }
    @ViewBuilder
    private func ritualSheet(for choice: Ritual) -> some View {
        RitualView(isIncense: choice == .incense).environmentObject(model)
            .presentationDetents([.height(ritualSheetHeight(for: choice))])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
            .presentationBackground(.clear)
    }
    private func ritualSheetHeight(for choice: Ritual) -> CGFloat {
        if choice == .incense { return 520 }
        return model.record.fortune == nil ? 510 : 560
    }
    private func ritualButton(_ title: String, symbol: String, status: String, kind: Ritual) -> some View {
        Button { model.refresh(); ritual = kind } label: {
            HStack(spacing: 9) {
                Image(systemName: symbol).font(.headline)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.subheadline)
                    Text(status).font(.caption2).foregroundStyle(mutedInk)
                }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 14).padding(.horizontal, 13)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).stroke(ink.opacity(colorScheme == .dark ? 0.14 : 0.10), lineWidth: 1) }
        }.buttonStyle(.plain)
    }
}

private struct InkMountainBackground: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            var far = Path()
            far.move(to: CGPoint(x: 0, y: h * 0.64))
            far.addLine(to: CGPoint(x: w * 0.10, y: h * 0.54))
            far.addLine(to: CGPoint(x: w * 0.24, y: h * 0.59))
            far.addLine(to: CGPoint(x: w * 0.43, y: h * 0.39))
            far.addLine(to: CGPoint(x: w * 0.58, y: h * 0.52))
            far.addLine(to: CGPoint(x: w * 0.73, y: h * 0.45))
            far.addLine(to: CGPoint(x: w, y: h * 0.58))
            far.addLine(to: CGPoint(x: w, y: h))
            far.addLine(to: CGPoint(x: 0, y: h))
            far.closeSubpath()
            context.fill(far, with: .linearGradient(Gradient(colors: [Color(red: 0.58, green: 0.65, blue: 0.60).opacity(0.34), Color(red: 0.42, green: 0.53, blue: 0.49).opacity(0.58)]), startPoint: CGPoint(x: 0, y: h * 0.35), endPoint: CGPoint(x: 0, y: h)))

            var near = Path()
            near.move(to: CGPoint(x: 0, y: h * 0.78))
            near.addLine(to: CGPoint(x: w * 0.18, y: h * 0.62))
            near.addLine(to: CGPoint(x: w * 0.31, y: h * 0.69))
            near.addLine(to: CGPoint(x: w * 0.52, y: h * 0.50))
            near.addLine(to: CGPoint(x: w * 0.66, y: h * 0.66))
            near.addLine(to: CGPoint(x: w * 0.83, y: h * 0.57))
            near.addLine(to: CGPoint(x: w, y: h * 0.71))
            near.addLine(to: CGPoint(x: w, y: h))
            near.addLine(to: CGPoint(x: 0, y: h))
            near.closeSubpath()
            context.fill(near, with: .color(Color(red: 0.22, green: 0.36, blue: 0.34).opacity(0.72)))

            var ridge = Path()
            ridge.move(to: CGPoint(x: w * 0.04, y: h * 0.84))
            ridge.addLine(to: CGPoint(x: w * 0.25, y: h * 0.73))
            ridge.addLine(to: CGPoint(x: w * 0.39, y: h * 0.80))
            ridge.addLine(to: CGPoint(x: w * 0.58, y: h * 0.66))
            ridge.addLine(to: CGPoint(x: w * 0.77, y: h * 0.82))
            ridge.addLine(to: CGPoint(x: w, y: h * 0.76))
            ridge.addLine(to: CGPoint(x: w, y: h))
            ridge.addLine(to: CGPoint(x: 0, y: h))
            ridge.closeSubpath()
            context.fill(ridge, with: .color(Color(red: 0.14, green: 0.27, blue: 0.27).opacity(0.78)))

            context.fill(Path(ellipseIn: CGRect(x: w * 0.72, y: h * 0.15, width: 44, height: 44)), with: .color(Color(red: 0.78, green: 0.76, blue: 0.62).opacity(0.46)))
            var mist = Path()
            mist.move(to: CGPoint(x: -20, y: h * 0.64))
            mist.addCurve(to: CGPoint(x: w + 20, y: h * 0.61), control1: CGPoint(x: w * 0.27, y: h * 0.55), control2: CGPoint(x: w * 0.67, y: h * 0.72))
            mist.addLine(to: CGPoint(x: w + 20, y: h * 0.70))
            mist.addCurve(to: CGPoint(x: -20, y: h * 0.72), control1: CGPoint(x: w * 0.64, y: h * 0.64), control2: CGPoint(x: w * 0.24, y: h * 0.78))
            mist.closeSubpath()
            context.fill(mist, with: .color(.white.opacity(0.13)))
        }
        .allowsHitTesting(false)
    }
}

private struct RitualView: View {
    let isIncense: Bool
    @EnvironmentObject private var model: RitualModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var inserted = false
    @State private var busy = false
    @State private var replay = false
    @State private var operation: Task<Void, Never>?
    private var offered: Bool { model.record.incense && !replay }
    private var sheetInk: Color { colorScheme == .dark ? Color(red: 0.93, green: 0.95, blue: 0.91) : Color(red: 0.22, green: 0.28, blue: 0.22) }
    private var sheetAccent: Color { colorScheme == .dark ? Color(red: 0.78, green: 0.70, blue: 0.42) : Color(red: 0.38, green: 0.44, blue: 0.32) }
    private var fortuneSurface: Color { colorScheme == .dark ? Color.white.opacity(0.10) : Color(red: 0.98, green: 0.97, blue: 0.93) }
    private var buttonText: Color { colorScheme == .dark ? Color(red: 0.10, green: 0.12, blue: 0.10) : Color(red: 0.97, green: 0.95, blue: 0.88) }
    private var sheetGradient: LinearGradient {
        colorScheme == .dark
            ? LinearGradient(
                colors: [Color(red: 0.09, green: 0.15, blue: 0.15), Color(red: 0.12, green: 0.20, blue: 0.19), Color(red: 0.07, green: 0.12, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [Color(red: 0.97, green: 0.96, blue: 0.90), Color(red: 0.88, green: 0.92, blue: 0.84), Color(red: 0.72, green: 0.81, blue: 0.74)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
    var body: some View {
        ZStack {
            sheetGradient
                .overlay {
                    RadialGradient(
                        colors: [Color.white.opacity(colorScheme == .dark ? 0.05 : 0.48), .clear],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: 430
                    )
                }
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text(Date.now, format: .dateTime.month().day())
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("关闭") { dismiss() }
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundStyle(sheetAccent)
                }
                .padding(.top, 18)

                Spacer(minLength: 14)

                VStack(spacing: 26) {
                    if isIncense {
                        Button(action: begin) {
                            IncenseScene(inserted: inserted || offered, smoking: offered, reduceMotion: reduceMotion)
                                .frame(height: 238)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .background(.white.opacity(colorScheme == .dark ? 0.07 : 0.20), in: RoundedRectangle(cornerRadius: 28))
                        }
                        .buttonStyle(.plain)
                        .disabled(busy || offered)
                        .accessibilityLabel("将香插入香炉")
                    } else if let index = model.record.fortune {
                        let fortune = DailyContent.fortunes[index]
                        VStack(spacing: 16) {
                            Text(fortune.title).font(.system(size: 48, weight: .regular, design: .serif))
                            Text(fortune.verse).font(.system(size: 21, design: .serif)).multilineTextAlignment(.center)
                            Text(fortune.reflection).font(.system(size: 15, design: .serif)).foregroundStyle(.secondary)
                                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 28)
                        .background(fortuneSurface.opacity(colorScheme == .dark ? 0.72 : 0.76), in: RoundedRectangle(cornerRadius: 20))
                        .overlay { RoundedRectangle(cornerRadius: 20).stroke(sheetAccent.opacity(0.30), lineWidth: 1) }
                    } else {
                        FortuneScene(shaking: busy, reduceMotion: reduceMotion)
                            .frame(maxWidth: .infinity)
                            .frame(height: 238)
                            .background(fortuneSurface.opacity(colorScheme == .dark ? 0.55 : 0.70), in: RoundedRectangle(cornerRadius: 20))
                    }

                    VStack(spacing: 8) {
                        Button(busy ? "静候…" : isIncense ? (offered ? "今日已上香" : "将香插入香炉") : (model.record.fortune == nil ? "静心抽签" : "收下今日签")) {
                            if (isIncense && offered) || (!isIncense && model.record.fortune != nil) { dismiss() } else { begin() }
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .frame(height: 49)
                        .background(sheetAccent, in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(buttonText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .tracking(2)
                        .disabled(busy)

                        if isIncense && model.record.incense && !replay {
                            Button("再体验一次") { replay = true; inserted = false }
                                .buttonStyle(.plain)
                                .foregroundStyle(sheetAccent)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .tracking(1.5)
                                .frame(height: 30)
                                .disabled(busy)
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .foregroundStyle(sheetInk)
        .onDisappear { operation?.cancel() }
    }
    private func begin() {
        guard !busy else { return }
        busy = true
        let day = DailyContent.dayKey()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 1.6)) { inserted = true }
        operation = Task { @MainActor in
            do { try await Task.sleep(for: .milliseconds(reduceMotion ? 100 : 1900)) } catch { return }
            guard !Task.isCancelled else { return }
            guard day == DailyContent.dayKey() else { model.refresh(); inserted = false; busy = false; return }
            if isIncense { model.offer(); replay = false } else { model.draw() }
            busy = false
        }
    }
}

private struct FortuneScene: View {
    let shaking: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            TimelineView(.animation(minimumInterval: 0.08, paused: reduceMotion || !shaking)) { context in
                let phase = reduceMotion ? 0.5 : context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 0.9) / 0.9
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [Color(red: 0.73, green: 0.64, blue: 0.46), Color(red: 0.88, green: 0.79, blue: 0.58)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 9, height: 93 + CGFloat(index % 2) * 12)
                        .rotationEffect(.degrees(shaking ? sin(phase * .pi * 2 + Double(index)) * 10 + Double(index - 2) * 3 : Double(index - 2) * 3), anchor: .bottom)
                        .offset(x: CGFloat(index - 2) * 12, y: shaking ? sin(phase * .pi * 2 + Double(index)) * 7 : 0)
                }
            }
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [Color(red: 0.39, green: 0.29, blue: 0.19), Color(red: 0.63, green: 0.49, blue: 0.31), Color(red: 0.34, green: 0.25, blue: 0.17)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 122, height: 100)
                .overlay { Text("玄\n序").font(.system(size: 19, design: .serif)).multilineTextAlignment(.center).foregroundStyle(Color(red: 0.88, green: 0.80, blue: 0.62)) }
                .overlay(alignment: .top) { Capsule().fill(Color(red: 0.28, green: 0.21, blue: 0.14)).frame(width: 122, height: 7).offset(y: -2) }
                .offset(y: 48)
        }
        .animation(.easeInOut(duration: reduceMotion ? 0 : 0.25), value: shaking)
        .accessibilityHidden(true)
    }
}

private struct IncenseScene: View {
    let inserted: Bool
    let smoking: Bool
    let reduceMotion: Bool
    var body: some View {
        ZStack {
            if smoking {
                TimelineView(.animation(minimumInterval: 0.08, paused: reduceMotion)) { context in
                    let phase = reduceMotion ? 0.5 : context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3) / 3
                    ForEach(0..<3) { i in
                        Capsule().fill(.gray.opacity(0.18)).frame(width: 4, height: 50).blur(radius: 4)
                            .rotationEffect(.degrees(Double(i * 12) - 12))
                            .offset(x: sin(phase * .pi * 2 + Double(i)) * 9, y: -96 - phase * 25)
                    }
                }
            }
            Rectangle().fill(LinearGradient(colors: [Color(red: 0.38, green: 0.31, blue: 0.24), Color(red: 0.64, green: 0.42, blue: 0.27)], startPoint: .top, endPoint: .bottom))
                .frame(width: 4, height: 125)
                .overlay(alignment: .top) { Circle().fill(.orange).frame(width: 5, height: 5).shadow(color: .orange, radius: 6) }
                .rotationEffect(.degrees(inserted ? 0 : 25), anchor: .bottom)
                .offset(x: inserted ? 0 : 55, y: inserted ? 0 : -48)
            if inserted {
                Ellipse().stroke(Color(red: 0.61, green: 0.67, blue: 0.50).opacity(0.55), lineWidth: 1)
                    .frame(width: 120, height: 34).scaleEffect(smoking ? 1.16 : 0.72).opacity(smoking ? 0.18 : 0.65).offset(y: 66)
            }
            Ellipse().fill(Color(red: 0.39, green: 0.46, blue: 0.35)).frame(width: 100, height: 18).offset(y: 65)
            UnevenRoundedRectangle(bottomLeadingRadius: 36, bottomTrailingRadius: 36)
                .fill(LinearGradient(colors: [Color(red: 0.40, green: 0.47, blue: 0.36), Color(red: 0.55, green: 0.59, blue: 0.46), Color(red: 0.30, green: 0.37, blue: 0.29)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 100, height: 45).overlay { Text("静").font(.system(.title3, design: .serif)).foregroundStyle(.white.opacity(0.7)) }.offset(y: 88)
        }
        .animation(.easeInOut(duration: reduceMotion ? 0 : 0.35), value: inserted)
        .accessibilityHidden(true)
    }
}
