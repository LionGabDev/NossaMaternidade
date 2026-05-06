//
//  PersonalLetterView.swift
//  MamaVida
//

import SwiftUI

/// Tela 4: Carta pessoal baseada na escolha emocional.
/// O app responde ao que a mãe sente — não com dados, com acolhimento.
struct PersonalLetterView: View {
    @Binding var didComplete: Bool

    @AppStorage("emotionalState") private var emotionalState: String = ""
    @State private var displayedLines: [String] = []
    @State private var currentLineIndex = 0
    @State private var currentCharIndex = 0
    @State private var showSignature = false
    @State private var showContinueHint = false
    @State private var letterOpacity: Double = 0

    private var letterContent: LetterContent {
        LetterContent.forState(emotionalState)
    }

    var body: some View {
        ZStack {
            // Fundo quente como papel envelhecido
            LinearGradient(
                colors: [
                    Color(hex: "#2A2520"),
                    Color(hex: "#1F1C18")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Textura sutil de papel
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                // Vinheta quente
                RadialGradient(
                    colors: [
                        Color(hex: "#D9876E").opacity(0.05),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 350
                )
            )

            // Conteúdo da carta
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 100)

                // Saudação
                Text("para você,")
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundStyle(Color(hex: "#D9876E").opacity(0.7))
                    .padding(.bottom, 24)
                    .opacity(letterOpacity)

                // Linhas da carta
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(0..<displayedLines.count, id: \.self) { index in
                        Text(displayedLines[index])
                            .font(.system(size: 18, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.88))
                            .lineSpacing(4)
                            .transition(.opacity.combined(with: .offset(y: 4)))
                    }

                    // Cursor piscando na linha atual
                    if currentLineIndex < letterContent.lines.count {
                        HStack(spacing: 0) {
                            Text(letterContent.lines[currentLineIndex].prefix(currentCharIndex))
                                .font(.system(size: 18, weight: .light, design: .serif))
                                .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.88))

                            CursorView()
                                .padding(.leading, 2)
                        }
                    }
                }

                Spacer()

                // Assinatura
                if showSignature {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("com carinho,")
                            .font(.system(size: 14, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.5))

                        Text("MamaVida")
                            .font(.system(size: 18, weight: .light, design: .serif).italic())
                            .foregroundStyle(Color(hex: "#D9876E").opacity(0.8))
                    }
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .offset(y: 8)))
                }

                // Hint para continuar
                if showContinueHint {
                    HStack {
                        Spacer()
                        Text("toque para seguir")
                            .font(.system(size: 13, weight: .thin, design: .rounded))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.3))
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 36)
            .opacity(letterOpacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                letterOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                startTyping()
            }
        }
        .onTapGesture {
            if showContinueHint {
                withAnimation(.easeInOut(duration: 0.8)) {
                    didComplete = true
                }
            }
        }
    }

    private func startTyping() {
        guard currentLineIndex < letterContent.lines.count else {
            finishLetter()
            return
        }

        let line = letterContent.lines[currentLineIndex]

        if currentCharIndex < line.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.045) {
                currentCharIndex += 1

                // Háptica sutil a cada poucos caracteres
                if currentCharIndex % 4 == 0 {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.15)
                }

                startTyping()
            }
        } else {
            // Linha completa
            displayedLines.append(line)
            currentLineIndex += 1
            currentCharIndex = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                startTyping()
            }
        }
    }

    private func finishLetter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 1.0)) {
                showSignature = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showContinueHint = true
            }
        }
    }
}

// MARK: - Cursor piscando

struct CursorView: View {
    @State private var isVisible = true

    var body: some View {
        Rectangle()
            .fill(Color(hex: "#D9876E").opacity(0.6))
            .frame(width: 2, height: 18)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isVisible = false
                }
            }
    }
}

// MARK: - Conteúdo da carta

struct LetterContent {
    let lines: [String]

    static func forState(_ state: String) -> LetterContent {
        switch state {
        case "Estou com medo":
            return LetterContent(lines: [
                "O medo é sinal de amor.",
                "E você já está amando",
                "muito bem.",
                "",
                "Cada mãe que passou por aqui",
                "também teve medo.",
                "Hoje elas respiram mais calmas.",
                "E você vai respirar também."
            ])
        case "Quero me sentir preparada":
            return LetterContent(lines: [
                "Preparação não é saber tudo.",
                "É saber que pode perguntar.",
                "",
                "Cada semana, um passo.",
                "Cada dúvida, uma resposta.",
                "Cada dia, mais perto.",
                "",
                "Vamos juntas, no seu ritmo."
            ])
        case "Preciso de alguém":
            return LetterContent(lines: [
                "Aqui tem gente que entende.",
                "Que já chorou do nada.",
                "Que já riu sozinha sentada.",
                "",
                "Você não está sozinha.",
                "Nunca esteve.",
                "",
                "Agora tem uma casa."
            ])
        default:
            return LetterContent(lines: [
                "Cada momento é único.",
                "Cada chute, cada soninho,",
                "cada barriga crescendo.",
                "",
                "A gente vai guardar tudo.",
                "Os bons, os difíceis,",
                "os que vão fazer você sorrir",
                "daqui a uns anos."
            ])
        }
    }
}

#Preview {
    PersonalLetterView(didComplete: .constant(false))
}
