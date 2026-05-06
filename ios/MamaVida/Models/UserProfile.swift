//
//  UserProfile.swift
//  MamaVida
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var userName: String
    var birthDate: Date?
    var lmpDate: Date
    var dueDate: Date
    var babyName: String
    var hasAcceptedTerms: Bool
    var notificationsEnabled: Bool
    var privateMode: Bool
    var language: String
    var createdAt: Date

    init(
        lmpDate: Date,
        dueDate: Date,
        babyName: String = "",
        userName: String = "",
        birthDate: Date? = nil,
        hasAcceptedTerms: Bool = false,
        notificationsEnabled: Bool = true,
        privateMode: Bool = false,
        language: String = "Português (Brasil)"
    ) {
        self.id = UUID()
        self.userName = userName
        self.birthDate = birthDate
        self.lmpDate = lmpDate
        self.dueDate = dueDate
        self.babyName = babyName
        self.hasAcceptedTerms = hasAcceptedTerms
        self.notificationsEnabled = notificationsEnabled
        self.privateMode = privateMode
        self.language = language
        self.createdAt = Date()
    }

    var currentWeek: Int {
        PregnancyCalculator.currentWeek(from: lmpDate)
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }

    var totalDaysOfPregnancy: Int {
        Calendar.current.dateComponents([.day], from: lmpDate, to: Date()).day ?? 0
    }
}
