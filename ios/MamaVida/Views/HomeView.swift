//
//  HomeView.swift
//  MamaVida
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \SymptomEntry.date, order: .reverse) private var entries: [SymptomEntry]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if let profile = profiles.first {
                        weekCard(profile: profile)
                        countdownCard(profile: profile)
                        tipsCard(week: profile.currentWeek)
                        quickActionsCard
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

    private func weekCard(profile: UserProfile) -> some View {
        let babySize = PregnancyCalculator.babySize(for: profile.currentWeek)
        return VStack(spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Semana \(profile.currentWeek)")
                        .font(AppFont.title)
                    Text("Seu bebê tem o tamanho de um(a) \(babySize.size)")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                Text(babySize.emoji)
                    .font(.system(size: 48))
            }

            HStack(spacing: AppSpacing.lg) {
                statView(value: "\(babySize.lengthCm) cm", label: "Comprimento")
                statView(value: "\(babySize.weightG) g", label: "Peso estimado")
            }
        }
        .roundedCard()
    }

    private func countdownCard(profile: UserProfile) -> some View {
        let days = profile.daysUntilDue
        return VStack(spacing: AppSpacing.sm) {
            Text("\(days)")
                .font(AppFont.largeNumber)
                .foregroundStyle(AppColor.coral)
            Text(days == 1 ? "dia restante" : "dias restantes")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            LinearGradient(colors: [AppColor.coralLight.opacity(0.3), AppColor.sand], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(.rect(cornerRadius: 20))
    }

    private func tipsCard(week: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Dicas do dia")
                .font(AppFont.title3)

            ForEach(PregnancyCalculator.tips(for: week), id: \.self) { tip in
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.sageGreen)
                        .font(.caption)
                    Text(tip)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                }
            }
        }
        .roundedCard()
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Ações rápidas")
                .font(AppFont.title3)

            HStack(spacing: AppSpacing.md) {
                quickActionButton(icon: "list.bullet.clipboard", title: "Sintoma", color: AppColor.sageGreen) {
                    // Navigate to diary
                }
                quickActionButton(icon: "stopwatch.fill", title: "Contração", color: AppColor.coral) {
                    // Navigate to contractions
                }
                quickActionButton(icon: "calendar.badge.plus", title: "Consulta", color: AppColor.sageDark) {
                    // Navigate to agenda
                }
            }
        }
        .roundedCard()
    }

    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(color.opacity(0.08))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func statView(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.title3)
                .foregroundStyle(AppColor.sageGreen)
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
