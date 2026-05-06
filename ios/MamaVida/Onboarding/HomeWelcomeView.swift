//
//  HomeWelcomeView.swift
//  MamaVida
//

import SwiftUI

/// Tela 5: Boas-vindas suave à casa.
/// Sem botão "Começar". Apenas uma transição orgânica para o lar.
struct HomeWelcomeView: View {
    @Binding var didComplete: Bool

    @State private var showLogo = false
    @State private var logoChars: [LogoChar] = []
    @State private var showTagline = false
    @State private var showGlow = false
    @State private var breathScale: CGFloat = 1.0

    private let logoText = "MamaVida"

    var body: some View {
        ZStack {
            // Fundo que respira
            LinearGradient(
                colors: [
                    Color(hex: "#A8B89F"),
                    Color(hex: "#8FA088")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Glow central
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#D9876E").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(breathScale)
                .opacity(showGlow ? 1 : 0)

            VStack(spacing: 16) {
                Spacer()

                // Logo letra por letra
                if showLogo {
                    HStack(spacing: 1) {
                        ForEach(logoChars) { char in
                            Text(char.character)
                                .font(.system(size: 38, weight: .light, design: .serif))
                                .foregroundStyle(Color(hex: "#F4EDE4"))
                                .opacity(char.isVisible ? 1 : 0)
                                .offset(y: char.isVisible ? 0 : 8)
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: logoChars)
                }

                // Tagline
                if showTagline {
                    Text("sua casa agora")
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.7))
                        .transition(.opacity.combined(with: .offset(y: 8)))
                }

                Spacer()
            }
            .padding(.vertical, 120)
        }
        .onAppear {
            setupLogoChars()
            animateSequence()
        }
    }

    private func setupLogoChars() {
        logoChars = logoText.map { LogoChar(character: String($0), isVisible: false) }
    }

    private func animateSequence() {
        // Mostra container do logo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showLogo = true
            }
        }

        // Anima letras uma a uma
        for index in logoChars.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(index) * 0.1) {
                withAnimation(.easeOut(duration: 0.4)) {
                    logoChars[index].isVisible = true
                }

                // Háptica sutil
                if index % 2 == 0 {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.2)
                }
            }
        }

        // Glow e respiração
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showGlow = true
            }

            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breathScale = 1.1
            }
        }

        // Tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showTagline = true
            }
        }

        // Transição automática para home
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeInOut(duration: 1.2)) {
                didComplete = true
            }
        }
    }
}

struct LogoChar: Identifiable, Equatable {
    let id = UUID()
    var character: String
    var isVisible: Bool
}

#Preview {
    HomeWelcomeView(didComplete: .constant(false))
}
