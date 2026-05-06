//
//  SymptomEntry.swift
//  MamaVida
//

import Foundation
import SwiftData

@Model
final class SymptomEntry {
    var id: UUID
    var date: Date
    var mood: Int
    var sleepHours: Double
    var nausea: Int
    var weightKg: Double
    var photoURL: String?
    var notes: String
    var createdAt: Date

    init(date: Date, mood: Int = 3, sleepHours: Double = 7.0, nausea: Int = 0, weightKg: Double = 0, photoURL: String? = nil, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.sleepHours = sleepHours
        self.nausea = nausea
        self.weightKg = weightKg
        self.photoURL = photoURL
        self.notes = notes
        self.createdAt = Date()
    }
}
