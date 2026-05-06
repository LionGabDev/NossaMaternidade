//
//  EmotionalChoiceView.swift
//  MamaVida
//

import SwiftUI

/// Tela 2: "O que te trouxe aqui hoje?"
/// Em vez de perguntar dados, perguntamos o que importa de verdade.
/// Cada escolha é um sentimento — e o app reconhece isso.
struct EmotionalChoiceView: View {
    @Binding var didComplete: Bool

    @AppStorage("emotionalState") private var emotionalState: String = ""
    @State private var selectedIndex: Int? = nil
    @State private var showQuestion = false
    @State private var showOptions = false
    @State private var cardScales: [CGFloat] = [1, 1, 1, 1]

    private let choices = [
        EmotionalChoice(
            text: "Estou com medo",
            subtitle: "e isso é normal",
            color: Color(hex: "#C4A77D"),
            icon: "cloud.rain.fill"
        ),
        EmotionalChoice(
            text: "Quero me sentir preparada",
            subtitle: "para cada etapa",
            color: Color(hex: "#7A9E7E"),
            icon: "leaf.fill"
        ),
        EmotionalChoice(
            text: "Preciso de alguém",
            subtitle: "que entenda",
            color: Color(hex: "#D9876E"),
            icon: "heart.fill"
        ),
        EmotionalChoice(
            text: "Quero acompanhar",
            subtitle: "cada momento",
            color: Color(hex: "#8FA0B8"),
            icon: "sun.max.fill"
        )
    ]

    var body: some View {
        ZStack {
            // Fundo quente como um abraço
            LinearGradient(
                colors: [
                    Color(hex: "#1A1A1A"),
                    Color(hex: "#252220")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Espaço superior
                Spacer().frame(height: 80)

                // Pergunta
                if showQuestion {
                    VStack(spacing: 8) {
                        Text("o que te trouxe")
                            .font(.system(size: 26, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.9))

                        Text("aqui hoje?")
                            .font(.system(size: 26, weight: .light, design: .serif))
                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.9))
                    }
                    .transition(.opacity.combined(with: .offset(y: 15)))
                    .padding(.bottom, 50)
                }

                // Opções emocionais
                if showOptions {
                    VStack(spacing: 12) {
                        ForEach(0..<choices.count, id: \.self) { index in
                            let choice = choices[index]
                            let isSelected = selectedIndex == index

                            Button {
                                selectChoice(at: index)
                            } label: {
                                HStack(spacing: 16) {
                                    // Ícone
                                    Image(systemName: choice.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(choice.color)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(choice.text)
                                            .font(.system(size: 17, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color(hex: "#F4EDE4"))

                                        Text(choice.subtitle)
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundStyle(Color(hex: "#F4EDE4").opacity(0.5))
                                    }

                                    Spacer()

                                    // Indicador sutil de seleção
                                    Circle()
                                        .stroke(choice.color.opacity(isSelected ? 1 : 0.3), lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                        .overlay {
                                            if isSelected {
                                                Circle()
                                                    .fill(choice.color)
                                                    .frame(width: 12, height: 12)
                                                    .transition(.scale)
                                            }
                                        }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "#F4EDE4").opacity(isSelected ? 0.08 : 0.03))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(choice.color.opacity(isSelected ? 0.3 : 0), lineWidth: 1)
                                        )
                                )
                                .scaleEffect(cardScales[index])
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity.combined(with: .offset(y: 20)))
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showQuestion = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showOptions = true
                }
            }
        }
    }

    private func selectChoice(at index: Int) {
        selectedIndex = index
        emotionalState = choices[index].text

        // Háptica emocional
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)

        // Animação de confirmação
        cardScales[index] = 0.97
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            cardScales[index] = 1.0
        }

        // Avança após um momento de reconhecimento
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.8)) {
                didComplete = true
            }
        }
    }
}

struct EmotionalChoice {
    let text: String
    let subtitle: String
    let color: Color
    let icon: String
}

#Preview {
    EmotionalChoiceView(didComplete: .constant(false))
}
