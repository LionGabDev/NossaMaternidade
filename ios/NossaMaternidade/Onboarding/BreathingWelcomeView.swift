//
//  BreathingWelcomeView.swift
//  NossaMaternidade
//

import SwiftUI

/// Tela 1: Ritual de respiração conjunta.
/// A usuária abre o app e o primeiro contato é um convite para respirar junto.
/// Sem dados, sem perguntas — apenas presença.
struct BreathingWelcomeView: View {
    @Binding var didComplete: Bool

    @State private var breathScale: CGFloat = 0.6
    @State private var breathOpacity: Double = 0.3
    @State private var showText = false
    @State private var textPhase = 0
    @State private var hasTouched = false
    @State private var touchRipple: CGFloat = 0
    @State private var completedCycles = 0
    @State private var canAdvance = false

    private let breathDuration: Double = 4.0

    var body: some View {
        ZStack {
            // Fundo que respira com ela
            Color(hex: "#1A1A1A")
                .ignoresSafeArea()

            // Halo externo sutil
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#7A9E7E").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 300
                    )
                )
                .scaleEffect(breathScale * 1.8)
                .opacity(breathOpacity * 0.5)

            // Círculo principal de respiração
            ZStack {
                Circle()
                    .fill(Color(hex: "#7A9E7E").opacity(0.08))
                    .frame(width: 280, height: 280)
                    .scaleEffect(breathScale)

                Circle()
                    .stroke(Color(hex: "#7A9E7E").opacity(0.25), lineWidth: 1)
                    .frame(width: 280, height: 280)
                    .scaleEffect(breathScale)

                // Núcleo quente
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#E8A598").opacity(0.2),
                                Color(hex: "#7A9E7E").opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(breathScale)
            }
            .opacity(breathOpacity)

            // Ripple ao tocar
            if hasTouched {
                Circle()
                    .stroke(Color(hex: "#E8A598").opacity(0.4 - Double(touchRipple) * 0.4), lineWidth: 2)
                    .frame(width: 100 + touchRipple * 200, height: 100 + touchRipple * 200)
                    .opacity(1 - Double(touchRipple))
            }

            // Texto que acompanha a respiração
            VStack(spacing: 16) {
                Spacer()

                if showText {
                    Group {
                        switch textPhase {
                        case 0:
                            Text("respira comigo")
                                .transition(.opacity.combined(with: .offset(y: 10)))
                        case 1:
                            Text("a gente faz junto")
                                .transition(.opacity.combined(with: .offset(y: 10)))
                        case 2:
                            Text("pronta?")
                                .transition(.opacity.combined(with: .offset(y: 10)))
                        default:
                            EmptyView()
                        }
                    }
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.85))
                    .animation(.easeInOut(duration: 1.2), value: textPhase)
                }

                // Indicador sutil de toque
                if canAdvance {
                    Text("toque para continuar")
                        .font(.system(size: 13, weight: .thin, design: .rounded))
                        .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.4))
                        .padding(.top, 40)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.vertical, 120)
        }
        .contentShape(Rectangle())
        .onAppear {
            startBreathingCycle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    showText = true
                }
            }
        }
        .onTapGesture {
            if canAdvance {
                withAnimation(.easeInOut(duration: 0.8)) {
                    didComplete = true
                }
            } else {
                triggerTouchFeedback()
            }
        }
    }

    private func startBreathingCycle() {
        // Inspira
        withAnimation(.easeInOut(duration: breathDuration)) {
            breathScale = 1.0
            breathOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
            // Expira
            withAnimation(.easeInOut(duration: breathDuration)) {
                breathScale = 0.6
                breathOpacity = 0.4
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + breathDuration) {
                completedCycles += 1

                if completedCycles == 1 {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        textPhase = 1
                    }
                }

                if completedCycles < 2 {
                    startBreathingCycle()
                } else {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        textPhase = 2
                        canAdvance = true
                    }
                    // Háptica de conclusão sutil
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.4)
                }
            }
        }
    }

    private func triggerTouchFeedback() {
        hasTouched = true
        touchRipple = 0

        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)

        withAnimation(.easeOut(duration: 0.8)) {
            touchRipple = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            hasTouched = false
        }
    }
}

#Preview {
    BreathingWelcomeView(didComplete: .constant(false))
}
