//
//  ProfileView.swift
//  MamaVida
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @AppStorage("onboardingEmotionalComplete") private var emotionalComplete: Bool = false
    @AppStorage("emotionalState") private var emotionalState: String = ""

    @State private var showDeleteAlert = false
    @State private var showResetAlert = false
    @State private var exportURL: URL?
    @State private var editingPersonal = false
    @State private var editingPregnancy = false
    @State private var showAbout = false
    @State private var importer = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if let profile = profiles.first {
                        userCard(profile: profile)
                        personalCard(profile: profile)
                        pregnancyCard(profile: profile)
                        preferencesCard(profile: profile)
                        dataSection
                        aboutSection
                    } else {
                        Text("Perfil não encontrado.")
                            .foregroundStyle(AppColor.textSecondary)
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
        .sheet(isPresented: $editingPersonal) {
            if let p = profiles.first {
                EditPersonalSheet(profile: p)
            }
        }
        .sheet(isPresented: $editingPregnancy) {
            if let p = profiles.first {
                EditPregnancySheet(profile: p)
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutSheet()
        }
        .alert("Apagar todos os dados?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Apagar", role: .destructive) { deleteAllData() }
        } message: {
            Text("Esta ação é permanente. Você perderá registros, consultas e contrações.")
        }
        .alert("Resetar onboarding?", isPresented: $showResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Resetar", role: .destructive) {
                emotionalComplete = false
                emotionalState = ""
            }
        } message: {
            Text("Você verá novamente o ritual de boas-vindas.")
        }
    }

    // MARK: - User card

    private func userCard(profile: UserProfile) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColor.sageGreen)
                    .frame(width: 64, height: 64)
                Text(initials(for: profile))
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.babyName.isEmpty ? "Mamãe" : "Mamãe da \(profile.babyName)")
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.charcoal)
                Text("Semana \(profile.currentWeek) • \(profile.totalDaysOfPregnancy) dias")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            Button {
                editingPersonal = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(AppColor.sageGreen)
            }
        }
        .roundedCard()
    }

    private func initials(for profile: UserProfile) -> String {
        let name = profile.userName.isEmpty ? (profile.babyName.isEmpty ? "M" : profile.babyName) : profile.userName
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    // MARK: - Personal card

    private func personalCard(profile: UserProfile) -> some View {
        sectionCard(title: "Dados pessoais", onEdit: { editingPersonal = true }) {
            infoRow(label: "Nome", value: profile.userName.isEmpty ? "—" : profile.userName)
            Divider()
            infoRow(label: "Data de nascimento", value: profile.birthDate.map { dateFormatter.string(from: $0) } ?? "—")
        }
    }

    // MARK: - Pregnancy card

    private func pregnancyCard(profile: UserProfile) -> some View {
        sectionCard(title: "Gravidez", onEdit: { editingPregnancy = true }) {
            infoRow(label: "DUM", value: dateFormatter.string(from: profile.lmpDate))
            Divider()
            infoRow(label: "DPP", value: dateFormatter.string(from: profile.dueDate))
            Divider()
            infoRow(label: "Semana atual", value: "\(profile.currentWeek) / 40")
        }
    }

    // MARK: - Preferences

    private func preferencesCard(profile: UserProfile) -> some View {
        let nBinding = Binding<Bool>(
            get: { profile.notificationsEnabled },
            set: { profile.notificationsEnabled = $0; try? modelContext.save() }
        )
        let pBinding = Binding<Bool>(
            get: { profile.privateMode },
            set: { profile.privateMode = $0; try? modelContext.save() }
        )

        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Preferências")
                .font(AppFont.title3)
                .foregroundStyle(AppColor.charcoal)
                .padding(.bottom, 4)

            Toggle(isOn: nBinding) {
                Label("Notificações", systemImage: "bell.fill")
                    .foregroundStyle(AppColor.charcoal)
            }
            .tint(AppColor.sageGreen)
            Divider()
            Toggle(isOn: pBinding) {
                Label("Modo privado", systemImage: "lock.fill")
                    .foregroundStyle(AppColor.charcoal)
            }
            .tint(AppColor.sageGreen)
            Divider()
            HStack {
                Label("Idioma", systemImage: "globe")
                    .foregroundStyle(AppColor.charcoal)
                Spacer()
                Text(profile.language)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .roundedCard()
    }

    // MARK: - Data

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Dados e segurança")
                .font(AppFont.title3)
                .foregroundStyle(AppColor.charcoal)
                .padding(.bottom, AppSpacing.sm)

            actionRow(icon: "arrow.up.doc", title: "Exportar sintomas (CSV)", color: AppColor.sageGreen) {
                if let url = DataExporter.exportSymptomsToCSV(context: modelContext) { exportURL = url }
            }
            Divider()
            actionRow(icon: "arrow.up.doc", title: "Exportar consultas (CSV)", color: AppColor.sageGreen) {
                if let url = DataExporter.exportAppointmentsToCSV(context: modelContext) { exportURL = url }
            }
            Divider()
            actionRow(icon: "square.and.arrow.down", title: "Importar dados", color: AppColor.sageGreen) {
                importer = true
            }
            Divider()
            actionRow(icon: "arrow.counterclockwise", title: "Resetar onboarding", color: AppColor.sageGreen) {
                showResetAlert = true
            }
            Divider()
            actionRow(icon: "trash", title: "Apagar todos os dados", color: AppColor.alertRed, destructive: true) {
                showDeleteAlert = true
            }
        }
        .roundedCard()
        .fileImporter(isPresented: $importer, allowedContentTypes: [.commaSeparatedText, .data]) { _ in
            // Stub: actual CSV import would parse files; left as future work.
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Sobre")
                .font(AppFont.title3)
                .foregroundStyle(AppColor.charcoal)
            infoRow(label: "Versão", value: "1.0")
            Divider()
            infoRow(label: "Desenvolvido para", value: "Nathalia Valente")
            Divider()
            Button {
                showAbout = true
            } label: {
                HStack {
                    Text("Contato e suporte")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.charcoal)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .frame(minHeight: 44)
        }
        .roundedCard()
    }

    // MARK: - Helpers

    private func sectionCard<Content: View>(title: String, onEdit: @escaping () -> Void, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(title)
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.charcoal)
                Spacer()
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(AppColor.sageGreen)
                }
            }
            .padding(.bottom, 4)
            content()
        }
        .roundedCard()
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.charcoal)
        }
        .padding(.vertical, 4)
    }

    private func actionRow(icon: String, title: String, color: Color, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
                Text(title)
                    .font(AppFont.body)
                    .foregroundStyle(destructive ? AppColor.alertRed : AppColor.charcoal)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
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

        emotionalComplete = false
        emotionalState = ""
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }
}

// MARK: - Edit sheets

struct EditPersonalSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile

    @State private var name: String
    @State private var birthDate: Date
    @State private var hasBirthDate: Bool

    init(profile: UserProfile) {
        self.profile = profile
        _name = State(initialValue: profile.userName)
        _birthDate = State(initialValue: profile.birthDate ?? Date(timeIntervalSince1970: 631152000))
        _hasBirthDate = State(initialValue: profile.birthDate != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nome") {
                    TextField("Como podemos te chamar?", text: $name)
                }
                Section("Data de nascimento") {
                    Toggle("Adicionar data", isOn: $hasBirthDate)
                        .tint(AppColor.sageGreen)
                    if hasBirthDate {
                        DatePicker("Nascimento", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    }
                }
                Section("Nome do bebê") {
                    TextField("Ex: Maria", text: $profile.babyName)
                }
            }
            .navigationTitle("Dados pessoais")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        profile.userName = name
                        profile.birthDate = hasBirthDate ? birthDate : nil
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditPregnancySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile

    @State private var lmpDate: Date

    init(profile: UserProfile) {
        self.profile = profile
        _lmpDate = State(initialValue: profile.lmpDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Data da última menstruação") {
                    DatePicker("DUM", selection: $lmpDate, in: ...Date(), displayedComponents: .date)
                }
                Section {
                    HStack {
                        Text("DPP")
                        Spacer()
                        Text(dateFormatter.string(from: PregnancyCalculator.dueDate(from: lmpDate)))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    HStack {
                        Text("Semana atual")
                        Spacer()
                        Text("\(PregnancyCalculator.currentWeek(from: lmpDate))")
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
            .navigationTitle("Gravidez")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        profile.lmpDate = lmpDate
                        profile.dueDate = PregnancyCalculator.dueDate(from: lmpDate)
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "pt_BR")
        return f
    }
}

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("MamaVida")
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.charcoal)
                    Text("Versão 1.0 — Desenvolvido para Nathalia Valente.")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)

                    Divider().padding(.vertical, 8)

                    Text("Contato e suporte")
                        .font(AppFont.title3)
                        .foregroundStyle(AppColor.charcoal)
                    Link("suporte@mamavida.app", destination: URL(string: "mailto:suporte@mamavida.app")!)
                        .foregroundStyle(AppColor.sageGreen)

                    Divider().padding(.vertical, 8)

                    Text("Aviso médico")
                        .font(AppFont.title3)
                        .foregroundStyle(AppColor.charcoal)
                    Text("O MamaVida é um aplicativo de acompanhamento pessoal e não substitui a orientação médica. Em qualquer sinal de alerta, procure atendimento.")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Sobre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
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
