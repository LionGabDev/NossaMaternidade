//
//  Appointment.swift
//  NossaMaternidade
//

import Foundation
import SwiftData
import SwiftUI

enum AppointmentType: String, CaseIterable, Identifiable {
    case consulta = "Consulta"
    case ultrassom = "Ultrassom"
    case vacina = "Vacina"
    case exame = "Exame"
    case outro = "Outro"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .consulta: return AppColor.typeConsulta
        case .ultrassom: return AppColor.typeUltrassom
        case .vacina: return AppColor.typeVacina
        case .exame: return AppColor.typeExame
        case .outro: return AppColor.secondaryGray
        }
    }

    var icon: String {
        switch self {
        case .consulta: return "stethoscope"
        case .ultrassom: return "waveform.path"
        case .vacina: return "syringe"
        case .exame: return "cross.case"
        case .outro: return "calendar"
        }
    }
}

@Model
final class Appointment {
    var id: UUID
    var type: String
    var dateTime: Date
    var location: String
    var doctor: String
    var notes: String
    var reminderEnabled: Bool
    var reminderSent24h: Bool
    var reminderSent2h: Bool
    var createdAt: Date

    init(
        type: String,
        dateTime: Date,
        location: String = "",
        doctor: String = "",
        notes: String = "",
        reminderEnabled: Bool = true
    ) {
        self.id = UUID()
        self.type = type
        self.dateTime = dateTime
        self.location = location
        self.doctor = doctor
        self.notes = notes
        self.reminderEnabled = reminderEnabled
        self.reminderSent24h = false
        self.reminderSent2h = false
        self.createdAt = Date()
    }

    var isPast: Bool {
        dateTime < Date()
    }

    var typeEnum: AppointmentType {
        AppointmentType(rawValue: type) ?? .outro
    }
}
