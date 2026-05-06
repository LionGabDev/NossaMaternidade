//
//  UserProfile.swift
//  MamaVida
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var lmpDate: Date
    var dueDate: Date
    var babyName: String
    var hasAcceptedTerms: Bool
    var createdAt: Date

    init(lmpDate: Date, dueDate: Date, babyName: String = "", hasAcceptedTerms: Bool = false) {
        self.id = UUID()
        self.lmpDate = lmpDate
        self.dueDate = dueDate
        self.babyName = babyName
        self.hasAcceptedTerms = hasAcceptedTerms
        self.createdAt = Date()
    }

    var currentWeek: Int {
        PregnancyCalculator.currentWeek(from: lmpDate)
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
}
