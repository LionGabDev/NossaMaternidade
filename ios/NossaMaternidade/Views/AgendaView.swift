//
//  AgendaView.swift
//  NossaMaternidade
//

import SwiftUI
import SwiftData
import EventKit

struct AgendaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appointment.dateTime, order: .forward) private var appointments: [Appointment]
    @State private var showAddSheet = false
    @State private var editing: Appointment?
    @State private var detailAppointment: Appointment?

    var upcomingAppointments: [Appointment] {
        appointments.filter { !$0.isPast }
    }

    var pastAppointments: [Appointment] {
        appointments.filter { $0.isPast }.reversed()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    if appointments.isEmpty {
                        emptyState
                    } else {
                        if !upcomingAppointments.isEmpty {
                            sectionHeader("Próximas")
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(upcomingAppointments) { appointment in
                                    AppointmentCard(appointment: appointment, onTap: { detailAppointment = appointment })
                                }
                            }
                        }

                        if !pastAppointments.isEmpty {
                            sectionHeader("Passadas")
                                .padding(.top, AppSpacing.sm)
                            VStack(spacing: AppSpacing.sm) {
                                ForEach(pastAppointments) { appointment in
                                    AppointmentCard(appointment: appointment, onTap: { detailAppointment = appointment })
                                        .opacity(0.65)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.md)
            }
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
                AppointmentFormSheet(existing: nil)
            }
            .sheet(item: $editing) { app in
                AppointmentFormSheet(existing: app)
            }
            .sheet(item: $detailAppointment) { app in
                AppointmentDetailSheet(appointment: app, onEdit: {
                    detailAppointment = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        editing = app
                    }
                }, onDelete: {
                    NotificationService.shared.cancelReminders(for: app.id)
                    modelContext.delete(app)
                    try? modelContext.save()
                    detailAppointment = nil
                })
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppFont.title3)
            .foregroundStyle(AppColor.charcoal)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.sageLight)
            Text("Nenhuma consulta agendada")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
            Button {
                showAddSheet = true
            } label: {
                Text("Adicionar consulta")
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
}

struct AppointmentCard: View {
    @Environment(\.modelContext) private var modelContext
    let appointment: Appointment
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(appointment.typeEnum.color)
                    .frame(width: 4)

                HStack(spacing: AppSpacing.md) {
                    VStack(spacing: 2) {
                        Text(dateFormatter.string(from: appointment.dateTime).uppercased())
                            .font(AppFont.captionMedium)
                            .foregroundStyle(appointment.typeEnum.color)
                        Text(timeFormatter.string(from: appointment.dateTime))
                            .font(AppFont.title3)
                            .foregroundStyle(AppColor.charcoal)
                    }
                    .frame(width: 70)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(appointment.type)
                            .font(AppFont.bodyMedium)
                            .foregroundStyle(AppColor.charcoal)
                        if !appointment.location.isEmpty {
                            Label(appointment.location, systemImage: "mappin.circle")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    Spacer(minLength: 0)

                    Image(systemName: appointment.reminderEnabled ? "bell.fill" : "bell.slash")
                        .font(.caption)
                        .foregroundStyle(appointment.reminderEnabled ? AppColor.sageGreen : AppColor.inactiveTab)
                }
                .padding(AppSpacing.md)
            }
            .background(AppColor.cardBackground)
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd MMM"
        f.locale = Locale(identifier: "pt_BR")
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "pt_BR")
        return f
    }
}

// MARK: - Detail sheet

struct AppointmentDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let appointment: Appointment
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false
    @State private var calendarMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Tipo", value: appointment.type)
                    LabeledContent("Data", value: longDateFormatter.string(from: appointment.dateTime))
                    LabeledContent("Hora", value: timeFormatter.string(from: appointment.dateTime))
                }

                if !appointment.location.isEmpty {
                    Section("Local") {
                        Text(appointment.location)
                    }
                }

                if !appointment.doctor.isEmpty {
                    Section("Médico(a)") {
                        Text(appointment.doctor)
                    }
                }

                if !appointment.notes.isEmpty {
                    Section("Notas") {
                        Text(appointment.notes)
                    }
                }

                Section {
                    Button {
                        addToCalendar()
                    } label: {
                        Label("Adicionar ao calendário", systemImage: "calendar.badge.plus")
                            .foregroundStyle(AppColor.sageGreen)
                    }
                    if let msg = calendarMessage {
                        Text(msg)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                Section {
                    Button("Editar") { onEdit() }
                        .foregroundStyle(AppColor.sageGreen)
                    Button("Apagar", role: .destructive) { showDeleteConfirm = true }
                }
            }
            .navigationTitle(appointment.type)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluído") { dismiss() }
                }
            }
            .confirmationDialog("Apagar consulta?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Apagar", role: .destructive) { onDelete() }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func addToCalendar() {
        let store = EKEventStore()
        store.requestFullAccessToEvents { granted, _ in
            DispatchQueue.main.async {
                guard granted else {
                    calendarMessage = "Permissão negada."
                    return
                }
                let event = EKEvent(eventStore: store)
                event.title = appointment.type
                event.startDate = appointment.dateTime
                event.endDate = appointment.dateTime.addingTimeInterval(3600)
                event.location = appointment.location
                event.notes = appointment.notes
                event.calendar = store.defaultCalendarForNewEvents
                do {
                    try store.save(event, span: .thisEvent)
                    calendarMessage = "Adicionado ao calendário."
                } catch {
                    calendarMessage = "Não foi possível adicionar."
                }
            }
        }
    }

    private var longDateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .full
        f.locale = Locale(identifier: "pt_BR")
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale(identifier: "pt_BR")
        return f
    }
}

// MARK: - Form sheet (add/edit)

struct AppointmentFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let existing: Appointment?

    @State private var type: AppointmentType = .consulta
    @State private var date: Date = Date().addingTimeInterval(3600)
    @State private var location: String = ""
    @State private var doctor: String = ""
    @State private var notes: String = ""
    @State private var reminderEnabled: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(AppointmentType.allCases) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                }

                Section("Data e hora") {
                    DatePicker("Quando", selection: $date)
                }

                Section("Local") {
                    TextField("Hospital ou clínica", text: $location)
                }

                Section("Médico(a)") {
                    TextField("Dra. Maria Silva", text: $doctor)
                }

                Section("Notas") {
                    TextField("Detalhes ou perguntas para a consulta", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section {
                    Toggle("Lembrete (24h e 2h antes)", isOn: $reminderEnabled)
                        .tint(AppColor.sageGreen)
                }
            }
            .navigationTitle(existing == nil ? "Nova consulta" : "Editar consulta")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadExisting() }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                }
            }
        }
    }

    private func loadExisting() {
        guard let e = existing else { return }
        type = e.typeEnum
        date = e.dateTime
        location = e.location
        doctor = e.doctor
        notes = e.notes
        reminderEnabled = e.reminderEnabled
    }

    private func save() {
        if let e = existing {
            NotificationService.shared.cancelReminders(for: e.id)
            e.type = type.rawValue
            e.dateTime = date
            e.location = location
            e.doctor = doctor
            e.notes = notes
            e.reminderEnabled = reminderEnabled
            if reminderEnabled {
                NotificationService.shared.scheduleAppointmentReminder(appointment: e)
            }
        } else {
            let appointment = Appointment(
                type: type.rawValue,
                dateTime: date,
                location: location,
                doctor: doctor,
                notes: notes,
                reminderEnabled: reminderEnabled
            )
            modelContext.insert(appointment)
            if reminderEnabled {
                NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
            }
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AgendaView()
        .modelContainer(for: Appointment.self, inMemory: true)
}
