//
//  NotificationService.swift
//  NossaMaternidade
//

import UserNotifications
import Foundation

@Observable
final class NotificationService {
    static let shared = NotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let settings = await notificationCenter.notificationSettings()
            if settings.authorizationStatus == .authorized {
                return true
            }
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func scheduleAppointmentReminder(appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Lembrete de Consulta"
        content.body = "\(appointment.type) em \(appointment.location)"
        content.sound = .default

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: appointment.dateTime)

        // 24h before
        if let reminderDate = calendar.date(byAdding: .hour, value: -24, to: appointment.dateTime),
           reminderDate > Date() {
            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "\(appointment.id.uuidString)-24h", content: content, trigger: trigger)
            notificationCenter.add(request)
        }

        // 2h before
        if let reminderDate = calendar.date(byAdding: .hour, value: -2, to: appointment.dateTime),
           reminderDate > Date() {
            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "\(appointment.id.uuidString)-2h", content: content, trigger: trigger)
            notificationCenter.add(request)
        }
    }

    func cancelReminders(for appointmentId: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            "\(appointmentId.uuidString)-24h",
            "\(appointmentId.uuidString)-2h"
        ])
    }
}
