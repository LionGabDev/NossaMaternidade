//
//  ProfileView.swift
//  MamaVida
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showDeleteAlert = false
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if let profile = profiles.first {
                        profileHeader(profile: profile)
                        pregnancyInfoCard(profile: profile)
                        dataSection
                        disclaimerSection
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Perfil")
        }
        .sheet(item: $exportURL) { url in
            ShareSheet(activityItems: [url])
        }
        .alert("Excluir conta", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Todos os seus dados serão permanentemente excluídos. Esta ação não pode ser desfeita.")
        }
    }

    private func profileHeader(profile: UserProfile) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppColor.sageGreen)

            Text(profile.babyName.isEmpty ? "Mamãe" : "Mamãe do(a) \(profile.babyName)")
                .font(AppFont.title2)

            Text("Semana \(profile.currentWeek) de gestação")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .roundedCard()
    }

    private func pregnancyInfoCard(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Informações da gestação")
                .font(AppFont.title3)

            infoRow(label: "DUM", value: dateFormatter.string(from: profile.lmpDate))
            Divider()
            infoRow(label: "DPP", value: dateFormatter.string(from: profile.dueDate))
            Divider()
            infoRow(label: "Semana atual", value: "\(profile.currentWeek)")
        }
        .roundedCard()
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Meus dados")
                .font(AppFont.title3)

            Button {
                if let url = DataExporter.exportSymptomsToCSV(context: modelContext) {
                    exportURL = url
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.doc")
                        .foregroundStyle(AppColor.sageGreen)
                    Text("Exportar sintomas (CSV)")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .frame(minHeight: 48)

            Divider()

            Button {
                if let url = DataExporter.exportAppointmentsToCSV(context: modelContext) {
                    exportURL = url
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.doc")
                        .foregroundStyle(AppColor.sageGreen)
                    Text("Exportar consultas (CSV)")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .frame(minHeight: 48)

            Divider()

            Button {
                showDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundStyle(AppColor.alertRed)
                    Text("Excluir todos os dados")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.alertRed)
                    Spacer()
                }
            }
            .frame(minHeight: 48)
        }
        .roundedCard()
    }

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Aviso médico")
                .font(AppFont.title3)

            Text("O MamaVida é um aplicativo de acompanhamento pessoal e não substitui a orientação médica. Sempre consulte seu obstetra para qualquer dúvida ou emergência. Em caso de sangramento, dor intensa ou qualquer sinal de alerta, procure atendimento médico imediato.")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(AppColor.cardBackground)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(AppFont.bodyMedium)
        }
    }

    private func deleteAllData() {
        let allSymptoms = try? modelContext.fetch(FetchDescriptor<SymptomEntry>())
        allSymptoms?.forEach { modelContext.delete($0) }

        let allAppointments = try? modelContext.fetch(FetchDescriptor<Appointment>())
        allAppointments?.forEach { modelContext.delete($0) }

        let allContractions = try? modelContext.fetch(FetchDescriptor<Contraction>())
        allContractions?.forEach { modelContext.delete($0) }

        let allProfiles = try? modelContext.fetch(FetchDescriptor<UserProfile>())
        allProfiles?.forEach { modelContext.delete($0) }

        try? modelContext.save()
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    ProfileView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
