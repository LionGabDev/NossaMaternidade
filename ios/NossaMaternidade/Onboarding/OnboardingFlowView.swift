//
//  OnboardingFlowView.swift
//  NossaMaternidade
//

import SwiftUI

/// Controlador do fluxo de onboarding emocional.
/// Cinco telas que constroem pertencimento passo a passo:
/// 1. Respiração conjunta — ritual de chegada
/// 2. Escolha emocional — o app reconhece quem ela é
/// 3. Constelação — visualização de comunidade
/// 4. Carta pessoal — resposta emocional à escolha
/// 5. Boas-vindas — transição orgânica para a home
struct OnboardingFlowView: View {
    @AppStorage("onboardingEmotionalComplete") private var emotionalComplete: Bool = false
    @State private var currentStep: Int = 0

    var body: some View {
        ZStack {
            switch currentStep {
            case 0:
                BreathingWelcomeView(didComplete: Binding(
                    get: { false },
                    set: { if $0 { advanceStep() } }
                ))
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))

            case 1:
                EmotionalChoiceView(didComplete: Binding(
                    get: { false },
                    set: { if $0 { advanceStep() } }
                ))
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))

            case 2:
                ConstellationView(didComplete: Binding(
                    get: { false },
                    set: { if $0 { advanceStep() } }
                ))
                .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))

            case 3:
                PersonalLetterView(didComplete: Binding(
                    get: { false },
                    set: { if $0 { advanceStep() } }
                ))
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))

            case 4:
                HomeWelcomeView(didComplete: Binding(
                    get: { false },
                    set: { if $0 { finishOnboarding() } }
                ))
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))

            default:
                Color.clear
            }
        }
        .animation(.easeInOut(duration: 0.8), value: currentStep)
    }

    private func advanceStep() {
        withAnimation(.easeInOut(duration: 0.8)) {
            currentStep += 1
        }
    }

    private func finishOnboarding() {
        withAnimation(.easeInOut(duration: 1.0)) {
            emotionalComplete = true
        }
    }
}

#Preview {
    OnboardingFlowView()
}
