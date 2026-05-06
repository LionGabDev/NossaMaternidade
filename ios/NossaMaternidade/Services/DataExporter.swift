//
//  DataExporter.swift
//  NossaMaternidade
//

import Foundation
import SwiftData

enum DataExporter {
    static func exportSymptomsToCSV(context: ModelContext) -> URL? {
        let descriptor = FetchDescriptor<SymptomEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        guard let entries = try? context.fetch(descriptor) else { return nil }

        var csv = "Data,Humor,Sono(horas),Náusea,Peso(kg),Notas\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"

        for entry in entries {
            let date = formatter.string(from: entry.date)
            let notes = entry.notes.replacingOccurrences(of: ",", with: " ")
            csv += "\(date),\(entry.mood),\(entry.sleepHours),\(entry.nausea),\(entry.weightKg),\(notes)\n"
        }

        let filename = "mamavida-sintomas-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    static func exportAppointmentsToCSV(context: ModelContext) -> URL? {
        let descriptor = FetchDescriptor<Appointment>(sortBy: [SortDescriptor(\.dateTime, order: .reverse)])
        guard let appointments = try? context.fetch(descriptor) else { return nil }

        var csv = "Data,Hora,Tipo,Local,Notas\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for appointment in appointments {
            let date = dateFormatter.string(from: appointment.dateTime)
            let time = timeFormatter.string(from: appointment.dateTime)
            let notes = appointment.notes.replacingOccurrences(of: ",", with: " ")
            csv += "\(date),\(time),\(appointment.type),\(appointment.location),\(notes)\n"
        }

        let filename = "mamavida-consultas-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
