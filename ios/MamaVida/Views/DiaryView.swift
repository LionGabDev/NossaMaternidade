//
//  DiaryView.swift
//  MamaVida
//

import SwiftUI
import SwiftData
import Charts
import PhotosUI

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomEntry.date, order: .reverse) private var entries: [SymptomEntry]
    @State private var selectedDate = Date()
    @State private var showAddSheet = false
    @State private var showCalendar = false

    var filteredEntries: [SymptomEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var last7DaysEntries: [SymptomEntry] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date())) ?? Date()
        return entries.filter { $0.date >= start }.sorted { $0.date < $1.date }
    }

    var last30DaysEntries: [SymptomEntry] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: Date())) ?? Date()
        return entries.filter { $0.date >= start }.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    dateSelector

                    if let entry = filteredEntries.first {
                        todayEntryCard(entry: entry)
                    } else {
                        noEntryCard
                    }

                    if !last7DaysEntries.isEmpty {
                        chartSection(title: "Últimos 7 dias - Peso (kg)", data: last7DaysEntries, keyPath: \.weightKg)
                        chartSection(title: "Últimos 7 dias - Sono (horas)", data: last7DaysEntries, keyPath: \.sleepHours)
                    }

                    if !last30DaysEntries.isEmpty {
                        chartSection(title: "Últimos 30 dias - Peso (kg)", data: last30DaysEntries, keyPath: \.weightKg)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Diário")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColor.sageGreen)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddSymptomSheet(date: selectedDate)
            }
        }
    }

    private var dateSelector: some View {
        HStack {
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(AppColor.sageGreen)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(dateFormatter.string(from: selectedDate))
                    .font(AppFont.title3)
                Text(isToday ? "Hoje" : "")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.sageGreen)
            }

            Spacer()

            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(AppColor.sageGreen)
            }
        }
        .padding()
        .background(AppColor.cardBackground)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private func todayEntryCard(entry: SymptomEntry) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Registro do dia")
                    .font(AppFont.title3)
                Spacer()
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(AppColor.sageGreen)
                }
            }

            HStack(spacing: AppSpacing.lg) {
                moodView(mood: entry.mood)
                statBadge(icon: "moon.fill", value: String(format: "%.1f", entry.sleepHours), label: "Sono", color: .indigo)
                statBadge(icon: "waveform.path.ecg", value: "\(entry.nausea)", label: "Náusea", color: AppColor.coral)
            }

            HStack {
                statBadge(icon: "scalemass.fill", value: String(format: "%.1f", entry.weightKg), label: "Peso (kg)", color: AppColor.sageGreen)
                Spacer()
            }

            if let photoURL = entry.photoURL, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 200)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .roundedCard()
    }

    private var noEntryCard: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.sageLight)
            Text("Nenhum registro para este dia")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
            Button {
                showAddSheet = true
            } label: {
                Text("Adicionar registro")
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColor.sageGreen)
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .roundedCard()
    }

    private func moodView(mood: Int) -> some View {
        let emojis = ["😢", "😕", "😐", "🙂", "😊"]
        let labels = ["Muito mal", "Mal", "Neutro", "Bem", "Muito bem"]
        let index = max(0, min(mood - 1, 4))
        return VStack(spacing: AppSpacing.xs) {
            Text(emojis[index])
                .font(.system(size: 32))
            Text(labels[index])
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private func statBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(AppFont.bodyMedium)
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(minWidth: 70)
    }

    private func chartSection(title: String, data: [SymptomEntry], keyPath: KeyPath<SymptomEntry, Double>) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.title3)

            Chart(data) { entry in
                LineMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Valor", entry[keyPath: keyPath])
                )
                .foregroundStyle(AppColor.sageGreen)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Valor", entry[keyPath: keyPath])
                )
                .foregroundStyle(AppColor.sageGreen.opacity(0.1))
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day())
                        .font(AppFont.caption)
                }
            }
        }
        .roundedCard()
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }
}

struct AddSymptomSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let date: Date

    @State private var mood: Int = 3
    @State private var sleepHours: Double = 7.0
    @State private var nausea: Int = 0
    @State private var weightKg: String = ""
    @State private var notes: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Humor") {
                    HStack {
                        ForEach(1...5, id: \.self) { i in
                            Button {
                                mood = i
                            } label: {
                                Text(moodEmoji(for: i))
                                    .font(.system(size: 32))
                                    .opacity(mood == i ? 1.0 : 0.4)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Sono (horas)") {
                    Slider(value: $sleepHours, in: 0...12, step: 0.5)
                    Text(String(format: "%.1f horas", sleepHours))
                        .foregroundStyle(AppColor.textSecondary)
                }

                Section("Náusea (0-5)") {
                    Picker("Náusea", selection: $nausea) {
                        ForEach(0...5, id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Peso (kg)") {
                    TextField("Ex: 65.5", text: $weightKg)
                        .keyboardType(.decimalPad)
                }

                Section("Foto da barriga") {
                    if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(selectedPhotoData == nil ? "Adicionar foto" : "Trocar foto", systemImage: "camera.fill")
                            .foregroundStyle(AppColor.sageGreen)
                    }
                }

                Section("Notas") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Novo registro")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedPhotoItem) { _, _ in
                loadPhoto()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { saveEntry() }
                        .disabled(weightKg.isEmpty)
                }
            }
        }
    }

    private func moodEmoji(for value: Int) -> String {
        ["😢", "😕", "😐", "🙂", "😊"][max(0, min(value - 1, 4))]
    }

    private func saveEntry() {
        guard let weight = Double(weightKg.replacingOccurrences(of: ",", with: ".")) else { return }

        var photoURL: String?
        if let data = selectedPhotoData {
            let filename = "belly-\(UUID().uuidString).jpg"
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
            try? data.write(to: url)
            photoURL = url.absoluteString
        }

        let entry = SymptomEntry(
            date: date,
            mood: mood,
            sleepHours: sleepHours,
            nausea: nausea,
            weightKg: weight,
            photoURL: photoURL,
            notes: notes
        )
        modelContext.insert(entry)
        try? modelContext.save()
        dismiss()
    }

    private func loadPhoto() {
        Task {
            if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedPhotoData = data
                }
            }
        }
    }
}

#Preview {
    DiaryView()
        .modelContainer(for: SymptomEntry.self, inMemory: true)
}
