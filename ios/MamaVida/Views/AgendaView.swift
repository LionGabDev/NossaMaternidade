//
//  AgendaView.swift
//  MamaVida
//

import SwiftUI
import SwiftData

struct AgendaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appointment.dateTime, order: .forward) private var appointments: [Appointment]
    @State private var showAddSheet = false

    var upcomingAppointments: [Appointment] {
        appointments.filter { !$0.isPast }
    }

    var pastAppointments: [Appointment] {
        appointments.filter { $0.isPast }
    }

    var body: some View {
        NavigationStack {
            List {
                if !upcomingAppointments.isEmpty {
                    Section("Próximas") {
                        ForEach(upcomingAppointments) { appointment in
                            AppointmentRow(appointment: appointment)
                        }
                        .onDelete(perform: deleteAppointments)
                    }
                }

                if !pastAppointments.isEmpty {
                    Section("Passadas") {
                        ForEach(pastAppointments) { appointment in
                            AppointmentRow(appointment: appointment)
                                .opacity(0.6)
                        }
                        .onDelete(perform: deleteAppointments)
                    }
                }

                if appointments.isEmpty {
                    Section {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 48))
                                .foregroundStyle(AppColor.sageLight)
                            Text("Nenhuma consulta agendada")
                                .font(AppFont.body)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xl)
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(AppColor.sand.ignoresSafeArea())
            .navigationTitle("Agenda")
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
                AddAppointmentSheet()
            }
        }
    }

    private func deleteAppointments(offsets: IndexSet) {
        for index in offsets {
            let appointment = index < upcomingAppointments.count ? upcomingAppointments[index] : pastAppointments[index - upcomingAppointments.count]
            NotificationService.shared.cancelReminders(for: appointment.id)
            modelContext.delete(appointment)
        }
        try? modelContext.save()
    }
}

struct AppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            dateBadge

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(appointment.type)
                    .font(AppFont.bodyMedium)
                if !appointment.location.isEmpty {
                    Text(appointment.location)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            Spacer()

            if !appointment.isPast {
                Button {
                    exportToCalendar(appointment)
                } label: {
                    Image(systemName: "arrow.up.doc")
                        .foregroundStyle(AppColor.sageGreen)
                }
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }

    private var dateBadge: some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: appointment.dateTime)
        return VStack {
            Text(String(format: "%02d", components.day ?? 0))
                .font(AppFont.title3)
                .foregroundStyle(AppColor.sageGreen)
            Text(monthAbbreviation(components.month ?? 1))
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(width: 48, height: 48)
        .background(AppColor.sageLight.opacity(0.2))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func monthAbbreviation(_ month: Int) -> String {
        let months = ["", "JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"]
        return months[month]
    }

    private func exportToCalendar(_ appointment: Appointment) {
        // Would use EventKit to add to device calendar
        // For MVP, this is a placeholder
    }
}

struct AddAppointmentSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var type: String = "Consulta pré-natal"
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var notes: String = ""

    let appointmentTypes = ["Consulta pré-natal", "Ultrassom", "Exame de sangue", "Vacina", "Outro"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(appointmentTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }

                Section("Data e hora") {
                    DatePicker("", selection: $date)
                        .datePickerStyle(.graphical)
                }

                Section("Local") {
                    TextField("Hospital ou clínica", text: $location)
                }

                Section("Notas") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Nova consulta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { saveAppointment() }
                }
            }
        }
    }

    private func saveAppointment() {
        let appointment = Appointment(
            type: type,
            dateTime: date,
            location: location,
            notes: notes
        )
        modelContext.insert(appointment)
        try? modelContext.save()
        NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
        dismiss()
    }
}

#Preview {
    AgendaView()
        .modelContainer(for: Appointment.self, inMemory: true)
}
