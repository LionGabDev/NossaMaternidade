//
//  OnboardingView.swift
//  NossaMaternidade
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var lmpDate: Date = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
    @State private var useUltrasound: Bool = false
    @State private var ultrasoundDate: Date = Date()
    @State private var babyName: String = ""
    @State private var hasAcceptedTerms: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    headerSection
                    inputSection
                    termsSection
                    continueButton
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xl)
            }
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Bem-vinda, mamãe!")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "heart.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppColor.coral)
                .padding(.bottom, AppSpacing.sm)

            Text("Vamos começar sua jornada")
                .font(AppFont.title2)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("Preencha algumas informações para personalizar seu acompanhamento.")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var inputSection: some View {
        VStack(spacing: AppSpacing.md) {
            Toggle("Usar data da ultrassom", isOn: $useUltrasound)
                .font(AppFont.bodyMedium)
                .tint(AppColor.sageGreen)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(useUltrasound ? "Data da ultrassom" : "Data da última menstruação (DUM)")
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.textSecondary)

                Button {
                    showDatePicker.toggle()
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(dateFormatter.string(from: useUltrasound ? ultrasoundDate : lmpDate))
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding()
                    .background(AppColor.cardBackground)
                    .clipShape(.rect(cornerRadius: 12))
                }

                if showDatePicker {
                    DatePicker(
                        "",
                        selection: useUltrasound ? $ultrasoundDate : $lmpDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding(.vertical, AppSpacing.sm)
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Nome do bebê (opcional)")
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.textSecondary)

                TextField("Ex: Maria, João", text: $babyName)
                    .font(AppFont.body)
                    .padding()
                    .background(AppColor.cardBackground)
                    .clipShape(.rect(cornerRadius: 12))
            }

            if let calculated = calculatedDueDate {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppColor.sageGreen)
                    Text("Data prevista do parto: \(dateFormatter.string(from: calculated))")
                        .font(AppFont.captionMedium)
                    Spacer()
                }
                .padding()
                .background(AppColor.sageLight.opacity(0.2))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .roundedCard()
    }

    private var termsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Button {
                    hasAcceptedTerms.toggle()
                } label: {
                    Image(systemName: hasAcceptedTerms ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(hasAcceptedTerms ? AppColor.sageGreen : AppColor.textSecondary)
                }

                Text("Li e concordo com a política de privacidade (LGPD). Seus dados são armazenados apenas no seu dispositivo e você pode exportá-los ou excluí-los a qualquer momento.")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    private var continueButton: some View {
        Button {
            saveProfile()
        } label: {
            HStack {
                Spacer()
                Text("Começar")
                    .font(AppFont.title3)
                Spacer()
            }
            .padding()
            .background(canContinue ? AppColor.sageGreen : AppColor.sageLight)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 16))
        }
        .disabled(!canContinue)
        .padding(.top, AppSpacing.md)
    }

    private var calculatedDueDate: Date? {
        if useUltrasound {
            return PregnancyCalculator.dueDate(from: ultrasoundDate)
        }
        return PregnancyCalculator.dueDate(from: lmpDate)
    }

    private var canContinue: Bool {
        hasAcceptedTerms && calculatedDueDate != nil
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }

    private func saveProfile() {
        guard let dueDate = calculatedDueDate else { return }
        let profile = UserProfile(
            lmpDate: useUltrasound ? ultrasoundDate : lmpDate,
            dueDate: dueDate,
            babyName: babyName,
            hasAcceptedTerms: hasAcceptedTerms
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
