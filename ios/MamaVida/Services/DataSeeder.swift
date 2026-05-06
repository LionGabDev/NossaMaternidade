//
//  DataSeeder.swift
//  MamaVida
//

import Foundation
import SwiftData

enum DataSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profiles = try? context.fetch(descriptor), profiles.isEmpty else { return }

        // Create demo user at 24 weeks
        let calendar = Calendar.current
        let lmpDate = calendar.date(byAdding: .day, value: -(24 * 7 - 7), to: Date()) ?? Date()
        let dueDate = PregnancyCalculator.dueDate(from: lmpDate)

        let profile = UserProfile(
            lmpDate: lmpDate,
            dueDate: dueDate,
            babyName: "Maria",
            hasAcceptedTerms: true
        )
        context.insert(profile)

        // Seed symptom entries for last 30 days
        for dayOffset in stride(from: 0, through: -29, by: -1) {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: Date())) else { continue }
            let entry = SymptomEntry(
                date: date,
                mood: Int.random(in: 2...5),
                sleepHours: Double.random(in: 5...9),
                nausea: Int.random(in: 0...3),
                weightKg: 65.0 + Double(dayOffset) * 0.05 + Double.random(in: -0.3...0.3),
                notes: ""
            )
            context.insert(entry)
        }

        // Seed appointments
        let appointmentTypes = ["Consulta pré-natal", "Ultrassom morfológico", "Exame de sangue", "Vacina", "Consulta com cardiologista"]
        let locations = ["Hospital São Lucas", "Clínica Maternal", "Laboratório Dasa", "UBS Centro", "Consultório Dra. Silva"]

        for i in 0..<5 {
            guard let date = calendar.date(byAdding: .day, value: i * 7 - 14, to: Date()) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 9 + i
            components.minute = 0
            let appointmentDate = calendar.date(from: components) ?? date

            let appointment = Appointment(
                type: appointmentTypes[i % appointmentTypes.count],
                dateTime: appointmentDate,
                location: locations[i % locations.count],
                notes: ""
            )
            context.insert(appointment)
        }

        // Seed contractions
        for i in 0..<8 {
            let startTime = Date().addingTimeInterval(-Double(i) * 3600 - Double.random(in: 0...600))
            let duration = Int.random(in: 30...90)
            let interval = i > 0 ? Int.random(in: 300...900) : 0
            let contraction = Contraction(
                startTime: startTime,
                endTime: startTime.addingTimeInterval(TimeInterval(duration)),
                durationSeconds: duration,
                intervalSeconds: interval
            )
            context.insert(contraction)
        }

        try? context.save()
    }
}
