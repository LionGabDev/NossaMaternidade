//
//  ContractionTimerView.swift
//  NossaMaternidade
//

import SwiftUI
import SwiftData

enum TimerState {
    case idle
    case running
    case paused
    case finished
}

struct ContractionTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contraction.startTime, order: .reverse) private var contractions: [Contraction]

    @State private var state: TimerState = .idle
    @State private var startTime: Date?
    @State private var pausedAccumulated: Int = 0
    @State private var pauseStartedAt: Date?
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var exportURL: URL?

    private var lastHourContractions: [Contraction] {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return contractions.filter { $0.startTime >= oneHourAgo && $0.endTime != nil }
    }

    private var last6: [Contraction] {
        Array(contractions.filter { $0.endTime != nil }.prefix(6))
    }

    /// 5-1-1: contractions ≤ 5 min apart, lasting ≥ 60s, for 1 hour.
    private var pattern511: Bool {
        let recent = last6
        guard recent.count >= 4 else { return false }
        let intervals = recent.map { $0.intervalSeconds }.filter { $0 > 0 }
        guard !intervals.isEmpty else { return false }
        let avgInterval = intervals.reduce(0, +) / intervals.count
        let avgDuration = recent.map { $0.durationSeconds }.reduce(0, +) / recent.count
        let lastHour = lastHourContractions.count
        return avgInterval <= 300 && avgDuration >= 60 && lastHour >= 6
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    patternBanner

                    timerCard

                    if !contractions.isEmpty {
                        historySection
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Contrações")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let url = exportCSV() { exportURL = url }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(AppColor.sageGreen)
                    }
                    .disabled(contractions.isEmpty)
                }
            }
            .sheet(item: $exportURL) { url in
                ShareSheet(activityItems: [url])
            }
        }
    }

    // MARK: - Pattern banner

    @ViewBuilder
    private var patternBanner: some View {
        if pattern511 {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Padrão 5-1-1 detectado.")
                        .font(AppFont.bodyMedium)
                    Text("Considere contatar seu médico.")
                        .font(AppFont.caption)
                }
                Spacer()
            }
            .padding()
            .background(AppColor.coral.opacity(0.18))
            .foregroundStyle(AppColor.charcoal)
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppColor.coral.opacity(0.55), lineWidth: 1)
            )
        } else if !contractions.isEmpty {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(AppColor.sageGreen)
                Text("Contrações irregulares • Continue monitorando")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColor.cardBackground)
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    // MARK: - Timer card

    private var timerCard: some View {
        VStack(spacing: AppSpacing.lg) {
            Text(stateLabel)
                .font(AppFont.title3)
                .foregroundStyle(AppColor.textSecondary)

            Text(formattedTime(elapsedSeconds))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(state == .running ? AppColor.coral : AppColor.sageGreen)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: elapsedSeconds)

            controlButtons
        }
        .padding(AppSpacing.lg)
        .background(AppColor.cardBackground)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private var stateLabel: String {
        switch state {
        case .idle: return "Toque em Iniciar para começar"
        case .running: return "Contração em andamento"
        case .paused: return "Pausado"
        case .finished: return "Última contração registrada"
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch state {
        case .idle:
            primaryButton(title: "Iniciar", icon: "play.fill", color: AppColor.sageGreen) { start() }

        case .running:
            HStack(spacing: AppSpacing.md) {
                secondaryButton(title: "Pausar", icon: "pause.fill", color: AppColor.sageGreen) { pause() }
                secondaryButton(title: "Parar", icon: "stop.fill", color: AppColor.coral) { stop() }
            }

        case .paused:
            HStack(spacing: AppSpacing.md) {
                secondaryButton(title: "Retomar", icon: "play.fill", color: AppColor.sageGreen) { resume() }
                secondaryButton(title: "Parar", icon: "stop.fill", color: AppColor.coral) { stop() }
            }

        case .finished:
            primaryButton(title: "Iniciar nova", icon: "play.fill", color: AppColor.sageGreen) { start() }
        }
    }

    private func primaryButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(AppFont.title3)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(color)
            .clipShape(.rect(cornerRadius: 18))
        }
    }

    private func secondaryButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(AppFont.bodyMedium)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(color)
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Histórico")
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.charcoal)
                Spacer()
                Text(lastHourSummary)
                    .font(AppFont.caption)
                    .foregroundStyle(lastHourContractions.isEmpty ? AppColor.textSecondary : AppColor.coral)
            }

            ForEach(contractions.prefix(20)) { contraction in
                HStack(spacing: AppSpacing.md) {
                    Text(timeFormatter.string(from: contraction.startTime))
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.charcoal)
                        .frame(width: 60, alignment: .leading)
                    Text("Duração \(contraction.formattedDuration)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    if contraction.intervalSeconds > 0 {
                        Text("Intervalo \(contraction.formattedInterval)")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.sageGreen)
                    }
                }
                .padding(.vertical, 6)
                if contraction.id != contractions.prefix(20).last?.id {
                    Divider()
                }
            }
        }
        .roundedCard()
    }

    private var lastHourSummary: String {
        let n = lastHourContractions.count
        if n == 0 { return "Nenhuma na última hora" }
        if n == 1 { return "1 contração na última hora" }
        return "\(n) contrações na última hora"
    }

    // MARK: - Timer logic

    private func formattedTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }

    private func start() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        startTime = Date()
        pausedAccumulated = 0
        pauseStartedAt = nil
        elapsedSeconds = 0
        state = .running
        startTicking()
    }

    private func pause() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        timer?.invalidate()
        timer = nil
        pauseStartedAt = Date()
        state = .paused
    }

    private func resume() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let p = pauseStartedAt {
            pausedAccumulated += Int(Date().timeIntervalSince(p))
        }
        pauseStartedAt = nil
        state = .running
        startTicking()
    }

    private func stop() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        timer?.invalidate()
        timer = nil

        if let start = startTime {
            let totalElapsed = Int(Date().timeIntervalSince(start)) - pausedAccumulated - (pauseStartedAt.map { Int(Date().timeIntervalSince($0)) } ?? 0)
            let duration = max(totalElapsed, 1)
            let lastContraction = contractions.first
            let interval = lastContraction != nil ? max(Int(start.timeIntervalSince(lastContraction!.startTime)), 0) : 0

            let contraction = Contraction(
                startTime: start,
                endTime: Date(),
                durationSeconds: duration,
                intervalSeconds: interval
            )
            modelContext.insert(contraction)
            try? modelContext.save()
        }

        elapsedSeconds = 0
        startTime = nil
        pausedAccumulated = 0
        pauseStartedAt = nil
        state = .finished
    }

    private func startTicking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    // MARK: - Export

    private func exportCSV() -> URL? {
        var csv = "Inicio,Fim,Duracao(s),Intervalo(s)\n"
        let formatter = ISO8601DateFormatter()
        for c in contractions {
            let endStr = c.endTime.map { formatter.string(from: $0) } ?? ""
            csv += "\(formatter.string(from: c.startTime)),\(endStr),\(c.durationSeconds),\(c.intervalSeconds)\n"
        }
        let filename = "mamavida-contracoes-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}

#Preview {
    ContractionTimerView()
        .modelContainer(for: Contraction.self, inMemory: true)
}
