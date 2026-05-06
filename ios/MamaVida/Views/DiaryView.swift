//
//  DiaryView.swift
//  MamaVida
//

import SwiftUI
import SwiftData
import Charts
import PhotosUI

enum DiaryMetric: String, CaseIterable, Identifiable {
    case peso = "Peso"
    case humor = "Humor"
    case sono = "Sono"
    case nausea = "Náusea"

    var id: String { rawValue }

    var unit: String {
        switch self {
        case .peso: return "kg"
        case .humor: return ""
        case .sono: return "h"
        case .nausea: return ""
        }
    }
}

struct DiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomEntry.date, order: .reverse) private var entries: [SymptomEntry]
    @State private var selectedDate = Date()
    @State private var showAddSheet = false
    @State private var selectedMetric: DiaryMetric = .peso

    var filteredEntries: [SymptomEntry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var last7DaysEntries: [SymptomEntry] {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date())) ?? Date()
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
                        chartCard
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
                AddSymptomSheet(date: selectedDate, existing: filteredEntries.first)
            }
        }
    }

    // MARK: - Date selector

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
                    .foregroundStyle(AppColor.charcoal)
                Text(isToday ? "Hoje" : "")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.sageGreen)
                    .frame(height: 14)
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

    private var isToday: Bool { Calendar.current.isDateInToday(selectedDate) }

    // MARK: - Today entry

    private func todayEntryCard(entry: SymptomEntry) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Registro do dia")
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.charcoal)
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

            if !entry.notes.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Notas")
                        .font(AppFont.captionMedium)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(entry.notes)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.charcoal)
                        .padding(AppSpacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.sand.opacity(0.6))
                        .clipShape(.rect(cornerRadius: 10))
                }
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

    // MARK: - Empty state

    private var noEntryCard: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.sageLight)
            Text("Nenhum registro para este dia")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
            Text("Como você se sente hoje?")
                .font(AppFont.caption)
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
        let emoji = moodEmoji(for: mood)
        let label = moodLabel(for: mood)
        return VStack(spacing: AppSpacing.xs) {
            Text(emoji)
                .font(.system(size: 32))
            Text(label)
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
                .foregroundStyle(AppColor.charcoal)
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(minWidth: 70)
    }

    // MARK: - Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Últimos 7 dias")
                .font(AppFont.title3)
                .foregroundStyle(AppColor.charcoal)

            Picker("Métrica", selection: $selectedMetric) {
                ForEach(DiaryMetric.allCases) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)

            Chart(last7DaysEntries) { entry in
                LineMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Valor", value(for: entry, metric: selectedMetric))
                )
                .foregroundStyle(AppColor.sageGreen)
                .interpolationMethod(.catmullRom)
                .symbol(.circle)

                AreaMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Valor", value(for: entry, metric: selectedMetric))
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColor.sageGreen.opacity(0.25), AppColor.sand.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.day())
                        .font(AppFont.caption)
                }
            }
        }
        .roundedCard()
    }

    private func value(for entry: SymptomEntry, metric: DiaryMetric) -> Double {
        switch metric {
        case .peso: return entry.weightKg
        case .humor: return Double(entry.mood)
        case .sono: return entry.sleepHours
        case .nausea: return Double(entry.nausea)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }
}

// MARK: - Helpers (file-private)

func moodEmoji(for value: Int) -> String {
    let emojis = ["😭", "😔", "😐", "🙂", "😊"]
    return emojis[max(0, min(value - 1, 4))]
}

func moodLabel(for value: Int) -> String {
    let labels = ["Muito mal", "Mal", "Neutro", "Bem", "Muito bem"]
    return labels[max(0, min(value - 1, 4))]
}

// MARK: - Add / Edit Sheet

struct AddSymptomSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let existing: SymptomEntry?

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
                Section("Como você se sentiu hoje?") {
                    HStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { i in
                            Button {
                                mood = i
                                UISelectionFeedbackGenerator().selectionChanged()
                            } label: {
                                VStack(spacing: 4) {
                                    Text(moodEmoji(for: i))
                                        .font(.system(size: 32))
                                        .opacity(mood == i ? 1.0 : 0.4)
                                    if mood == i {
                                        Circle()
                                            .fill(AppColor.sageGreen)
                                            .frame(width: 4, height: 4)
                                    } else {
                                        Color.clear.frame(width: 4, height: 4)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 4)
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
                    TextField("Como você se sentiu hoje?", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(existing == nil ? "Novo registro" : "Editar registro")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadExisting() }
            .onChange(of: selectedPhotoItem) { _, _ in loadPhoto() }
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

    private func loadExisting() {
        guard let e = existing else { return }
        mood = e.mood
        sleepHours = e.sleepHours
        nausea = e.nausea
        weightKg = String(format: "%.1f", e.weightKg)
        notes = e.notes
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

        if let e = existing {
            e.mood = mood
            e.sleepHours = sleepHours
            e.nausea = nausea
            e.weightKg = weight
            e.notes = notes
            if let p = photoURL { e.photoURL = p }
        } else {
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
        }
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
