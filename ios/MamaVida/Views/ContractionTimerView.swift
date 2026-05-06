//
//  ContractionTimerView.swift
//  MamaVida
//

import SwiftUI
import SwiftData

struct ContractionTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contraction.startTime, order: .reverse) private var contractions: [Contraction]

    @State private var isTiming = false
    @State private var startTime: Date?
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var showAlert = false

    private var lastHourContractions: [Contraction] {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return contractions.filter { $0.startTime >= oneHourAgo && $0.endTime != nil }
    }

    private var shouldShowAlert: Bool {
        let completed = contractions.filter { $0.endTime != nil }
        guard completed.count >= 5 else { return false }

        let last5 = Array(completed.prefix(5))
        let intervals = last5.compactMap { $0.intervalSeconds }
        guard intervals.count >= 4 else { return false }

        let avgInterval = intervals.reduce(0, +) / intervals.count
        return avgInterval <= 300 // 5 minutes
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    if shouldShowAlert {
                        alertBanner
                    }

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
        }
    }

    private var alertBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Regra 5-1-1 atingida!")
                    .font(AppFont.bodyMedium)
                Text("Considere ir ao hospital")
                    .font(AppFont.caption)
            }
            Spacer()
        }
        .padding()
        .background(AppColor.alertRed.opacity(0.1))
        .foregroundStyle(AppColor.alertRed)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.alertRed.opacity(0.3), lineWidth: 1)
        )
    }

    private var timerCard: some View {
        VStack(spacing: AppSpacing.lg) {
            Text(isTiming ? "Contração em andamento" : "Toque para iniciar")
                .font(AppFont.title3)
                .foregroundStyle(AppColor.textSecondary)

            Text(formattedTime(elapsedSeconds))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(isTiming ? AppColor.coral : AppColor.sageGreen)
                .monospacedDigit()

            Button {
                toggleTimer()
            } label: {
                HStack {
                    Image(systemName: isTiming ? "stop.fill" : "play.fill")
                    Text(isTiming ? "Parar" : "Iniciar")
                }
                .font(AppFont.title2)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(isTiming ? AppColor.coral : AppColor.sageGreen)
                .clipShape(.rect(cornerRadius: 20))
            }
            .frame(minHeight: 60)
        }
        .padding(AppSpacing.lg)
        .background(AppColor.cardBackground)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Histórico")
                .font(AppFont.title3)

            if !lastHourContractions.isEmpty {
                Text("\(lastHourContractions.count) contrações na última hora")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.coral)
            }

            ForEach(contractions.prefix(20)) { contraction in
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(timeFormatter.string(from: contraction.startTime))
                            .font(AppFont.bodyMedium)
                        if contraction.intervalSeconds > 0 {
                            Text("Intervalo: \(contraction.formattedInterval)")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }

                    Spacer()

                    Text(contraction.formattedDuration)
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.sageGreen)
                }
                .padding(.vertical, AppSpacing.sm)
            }
        }
        .roundedCard()
    }

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

    private func toggleTimer() {
        if isTiming {
            // Stop
            timer?.invalidate()
            timer = nil
            isTiming = false

            if let start = startTime {
                let duration = Int(Date().timeIntervalSince(start))
                let lastContraction = contractions.first
                let interval = lastContraction != nil ? Int(start.timeIntervalSince(lastContraction!.startTime)) : 0

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
        } else {
            // Start
            startTime = Date()
            isTiming = true
            elapsedSeconds = 0

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedSeconds += 1
            }
        }
    }
}

#Preview {
    ContractionTimerView()
        .modelContainer(for: Contraction.self, inMemory: true)
}
