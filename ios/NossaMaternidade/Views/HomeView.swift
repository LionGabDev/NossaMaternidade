//
//  HomeView.swift
//  NossaMaternidade
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if let profile = profiles.first {
                        progressRingCard(profile: profile)
                        countdownCard(profile: profile)
                        milestoneCard(week: profile.currentWeek)
                        communityCard(week: profile.currentWeek)
                        tipsCard(week: profile.currentWeek)
                    } else {
                        Text("Carregando...")
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Hoje")
        }
    }

    // MARK: - Progress ring

    private func progressRingCard(profile: UserProfile) -> some View {
        let week = profile.currentWeek
        let target = 40
        let progress = min(Double(week) / Double(target), 1.0)

        return VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .stroke(AppColor.sageGreen.opacity(0.12), lineWidth: 14)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [AppColor.sageGreen, AppColor.sageDark, AppColor.sageGreen],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                    .animation(.easeOut(duration: 1.0), value: progress)

                // Terracotta accent for current
                Circle()
                    .trim(from: max(0, progress - 0.015), to: progress)
                    .stroke(AppColor.coral, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)

                VStack(spacing: 2) {
                    Text("\(week)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColor.charcoal)
                    Text("de \(target) semanas")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .padding(.top, AppSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .roundedCard()
    }

    // MARK: - Countdown

    private func countdownCard(profile: UserProfile) -> some View {
        let days = profile.daysUntilDue
        return VStack(spacing: AppSpacing.xs) {
            Text("\(days)")
                .font(AppFont.largeNumber)
                .foregroundStyle(AppColor.coral)
            Text(days == 1 ? "dia para conhecer você" : "dias para conhecer você")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            LinearGradient(colors: [AppColor.coralLight.opacity(0.4), AppColor.sand], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(.rect(cornerRadius: 20))
    }

    // MARK: - Milestone card

    private func milestoneCard(week: Int) -> some View {
        let info = PregnancyCalculator.babySize(for: week)
        return HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColor.sageGreen.opacity(0.12))
                    .frame(width: 56, height: 56)
                Text(info.emoji)
                    .font(.system(size: 30))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Marco da semana")
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.sageGreen)
                Text(milestoneText(info: info))
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.charcoal)
            }
            Spacer(minLength: 0)
        }
        .roundedCard()
    }

    private func milestoneText(info: BabySizeInfo) -> String {
        if info.lengthCm > 0 && info.weightG > 0 {
            return "Seu bebê mede \(info.lengthCm) cm, \(info.weightG) g"
        } else if info.lengthCm > 0 {
            return "Seu bebê mede cerca de \(info.lengthCm) cm"
        }
        return "Tamanho de \(info.size.lowercased())"
    }

    // MARK: - Community card

    private func communityCard(week: Int) -> some View {
        // Symbolic count based on week (deterministic, no API).
        let count = 800 + (week * 47) % 1500
        return HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColor.coral.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(AppColor.coral)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedNumber(count))
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.charcoal)
                Text("mães na semana \(week) agora")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .roundedCard()
    }

    private func formattedNumber(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "pt_BR")
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    // MARK: - Tips

    private func tipsCard(week: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Dicas do dia")
                .font(AppFont.title3)
                .foregroundStyle(AppColor.charcoal)

            ForEach(PregnancyCalculator.tips(for: week), id: \.self) { tip in
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Circle()
                        .fill(AppColor.sageGreen)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    Text(tip)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.charcoal)
                    Spacer(minLength: 0)
                }
            }
        }
        .roundedCard()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
