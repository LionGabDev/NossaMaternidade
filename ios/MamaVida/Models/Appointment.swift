//
//  Appointment.swift
//  MamaVida
//

import Foundation
import SwiftData

@Model
final class Appointment {
    var id: UUID
    var type: String
    var dateTime: Date
    var location: String
    var notes: String
    var reminderSent24h: Bool
    var reminderSent2h: Bool
    var createdAt: Date

    init(type: String, dateTime: Date, location: String = "", notes: String = "") {
        self.id = UUID()
        self.type = type
        self.dateTime = dateTime
        self.location = location
        self.notes = notes
        self.reminderSent24h = false
        self.reminderSent2h = false
        self.createdAt = Date()
    }

    var isPast: Bool {
        dateTime < Date()
    }
}
