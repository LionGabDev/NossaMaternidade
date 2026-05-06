//
//  ConstellationView.swift
//  MamaVida
//

import SwiftUI

/// Tela 3: Constelação de mães.
/// Pontos luminosos representam outras mães. A dela aparece no centro.
/// Visualização poderosa de "você não está sozinha".
struct ConstellationView: View {
    @Binding var didComplete: Bool

    @State private var stars: [Star] = []
    @State private var showText = false
    @State private var userStarScale: CGFloat = 0
    @State private var userStarOpacity: Double = 0
    @State private var connectionLines: Bool = false
    @State private var canAdvance = false

    private let starCount = 45

    var body: some View {
        ZStack {
            // Fundo noturno profundo
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()

            // Estrelas/fogos distantes
            ForEach(stars) { star in
                StarView(star: star, isUserStar: false)
            }

            // Linhas de conexão sutis
            if connectionLines {
                ConnectionLinesView(stars: stars)
                    .opacity(0.15)
                    .allowsHitTesting(false)
            }

            // Estrela da usuária (centro)
            ZStack {
                // Halo pulsante
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#E8A598").opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(userStarScale)
                    .opacity(userStarOpacity)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: userStarScale > 0.5
                    )

                // Estrela central
                Circle()
                    .fill(Color(hex: "#E8A598"))
                    .frame(width: 14, height: 14)
                    .shadow(color: Color(hex: "#E8A598").opacity(0.6), radius: 12, x: 0, y: 0)
                    .scaleEffect(userStarScale)
                    .opacity(userStarOpacity)
            }

            // Texto
            VStack(spacing: 12) {
                Spacer()

                if showText {
                    VStack(spacing: 10) {
                        Text("milhares de mães")
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.85))
                            .transition(.opacity.combined(with: .offset(y: 10)))

                        Text("respiram com você agora")
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.85))
                            .transition(.opacity.combined(with: .offset(y: 10)))
                    }
                }

                if canAdvance {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
                        withAnimation(.easeInOut(duration: 0.8)) {
                            didComplete = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .light))
                            Text("suba para continuar")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.85))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .stroke(Color(hex: "#F4EDE4").opacity(0.3), lineWidth: 0.8)
                        )
                    }
                    .padding(.top, 28)
                    .transition(.opacity.combined(with: .offset(y: 6)))
                }

                Spacer().frame(height: 60)

                OnboardingProgressDots(total: 5, current: 2)
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            generateStars()
            animateSequence()
        }
    }

    private func generateStars() {
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height

        for _ in 0..<starCount {
            let star = Star(
                position: CGPoint(
                    x: CGFloat.random(in: 30...(screenW - 30)),
                    y: CGFloat.random(in: 60...(screenH - 120))
                ),
                size: CGFloat.random(in: 3...7),
                opacity: Double.random(in: 0.3...0.8),
                pulseDuration: Double.random(in: 2...5),
                pulseDelay: Double.random(in: 0...3)
            )
            stars.append(star)
        }
    }

    private func animateSequence() {
        // Estrelas aparecem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 1.5)) {
                for index in stars.indices {
                    stars[index].isVisible = true
                }
            }
        }

        // Estrela da usuária nasce
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)

            withAnimation(.easeOut(duration: 1.0)) {
                userStarScale = 1.0
                userStarOpacity = 1.0
            }
        }

        // Linhas de conexão
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                connectionLines = true
            }
        }

        // Texto
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 1.2)) {
                showText = true
            }
        }

        // Pode avançar
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                canAdvance = true
            }
        }
    }
}

// MARK: - Star Model

struct Star: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var pulseDuration: Double
    var pulseDelay: Double
    var isVisible: Bool = false
}

// MARK: - Star View

struct StarView: View {
    let star: Star
    let isUserStar: Bool

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 1.0

    var body: some View {
        Circle()
            .fill(isUserStar ? Color(hex: "#E8A598") : Color(hex: "#F4EDE4"))
            .frame(width: star.size, height: star.size)
            .opacity(star.isVisible ? star.opacity * pulseOpacity : 0)
            .scaleEffect(pulseScale)
            .position(star.position)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: star.pulseDuration)
                    .repeatForever(autoreverses: true)
                    .delay(star.pulseDelay)
                ) {
                    pulseScale = 1.3
                    pulseOpacity = 0.6
                }
            }
    }
}

// MARK: - Connection Lines

struct ConnectionLinesView: View {
    let stars: [Star]

    var body: some View {
        Canvas { context, size in
            for i in 0..<stars.count {
                for j in (i + 1)..<stars.count {
                    let starA = stars[i]
                    let starB = stars[j]

                    let distance = hypot(starB.position.x - starA.position.x, starB.position.y - starA.position.y)

                    if distance < 120 {
                        var path = Path()
                        path.move(to: starA.position)
                        path.addLine(to: starB.position)

                        context.stroke(
                            path,
                            with: .color(Color(hex: "#F4EDE4").opacity(0.3 * (1 - distance / 120))),
                            lineWidth: 0.5
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    ConstellationView(didComplete: .constant(false))
}
