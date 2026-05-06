//
//  Theme.swift
//  MamaVida
//

import SwiftUI

/// Locked design tokens for MamaVida.
/// Primary sage, terracotta, sand, charcoal — no other hues for UI chrome.
enum AppColor {
    static let sageGreen = Color(hex: "#7A9E7E")        // primary
    static let sageLight = Color(hex: "#A8C4AB")        // lighter sage for soft backgrounds
    static let sageDark = Color(hex: "#5A7E5E")         // accent
    static let sand = Color(hex: "#F4EDE4")             // background
    static let sandDark = Color(hex: "#E8E2D6")
    static let coral = Color(hex: "#E8A598")            // terracotta
    static let coralLight = Color(hex: "#F2C9C0")
    static let charcoal = Color(hex: "#1A1A1A")         // text primary
    static let secondaryGray = Color(hex: "#6B6B6B")    // text secondary
    static let inactiveTab = Color(hex: "#B8B8B8")
    static let textPrimary = Color(hex: "#1A1A1A")
    static let textSecondary = Color(hex: "#6B6B6B")
    static let cardBackground = Color.white
    static let alertRed = Color(hex: "#D9534F")

    // Appointment color coding
    static let typeConsulta = Color(hex: "#7A9E7E")
    static let typeUltrassom = Color(hex: "#4A90E2")
    static let typeVacina = Color(hex: "#FF9500")
    static let typeExame = Color(hex: "#9B59B6")
}

enum AppFont {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 16, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
    static let captionMedium = Font.system(size: 14, weight: .medium, design: .rounded)
    static let largeNumber = Font.system(size: 48, weight: .bold, design: .rounded)
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RoundedCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.md)
            .background(AppColor.cardBackground)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func roundedCard() -> some View {
        modifier(RoundedCardModifier())
    }
}

/// Onboarding progress dots for screens 2-5 of the emotional flow.
/// Total = 5 steps. Filled (●) for current+past, hollow (○) for future.
struct OnboardingProgressDots: View {
    let total: Int
    let current: Int
    var color: Color = Color(hex: "#F4EDE4")

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index <= current ? color.opacity(0.9) : color.opacity(0.25))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
