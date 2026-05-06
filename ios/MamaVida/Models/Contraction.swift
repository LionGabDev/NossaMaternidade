//
//  Contraction.swift
//  MamaVida
//

import Foundation
import SwiftData

@Model
final class Contraction {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var durationSeconds: Int
    var intervalSeconds: Int
    var createdAt: Date

    init(startTime: Date, endTime: Date? = nil, durationSeconds: Int = 0, intervalSeconds: Int = 0) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.durationSeconds = durationSeconds
        self.intervalSeconds = intervalSeconds
        self.createdAt = Date()
    }

    var isActive: Bool {
        endTime == nil
    }

    var formattedDuration: String {
        let mins = durationSeconds / 60
        let secs = durationSeconds % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }

    var formattedInterval: String {
        let mins = intervalSeconds / 60
        let secs = intervalSeconds % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}
