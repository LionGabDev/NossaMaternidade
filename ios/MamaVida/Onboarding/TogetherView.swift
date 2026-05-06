//
//  TogetherView.swift
//  MamaVida
//

import SwiftUI

/// Tela 5: Estamos juntas.
/// Mãos entrelaçadas se desenhando com stroke animation.
/// Transição automática para a home após 2.5s.
struct TogetherView: View {
    @Binding var didComplete: Bool

    @State private var strokeProgress: CGFloat = 0.0
    @State private var showText = false
    @State private var textOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Fundo gradiente sálvia → areia
            LinearGradient(
                colors: [
                    Color(hex: "#7A9E7E"),
                    Color(hex: "#F4EDE4")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Mãos entrelaçadas (uma maior, uma pequena)
                ZStack {
                    HandsShape()
                        .trim(from: 0, to: strokeProgress)
                        .stroke(
                            Color(hex: "#E8A598"),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: Color(hex: "#E8A598").opacity(0.3), radius: 10, x: 0, y: 4)
                }

                Text("estamos juntas")
                    .font(.system(.title, design: .serif).italic())
                    .foregroundStyle(Color(hex: "#1A1A1A"))
                    .opacity(textOpacity)
                    .offset(y: showText ? 0 : 15)
                    .animation(.easeInOut(duration: 1.0), value: showText)

                Spacer()
            }
            .padding(.vertical, 80)
        }
        .onAppear {
            // Anima o desenho das mãos
            withAnimation(.easeInOut(duration: 1.5)) {
                strokeProgress = 1.0
            }

            // Mostra o texto
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showText = true
                    textOpacity = 1.0
                }
            }

            // Transição automática para a home
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    didComplete = true
                }
            }
        }
    }
}

/// Shape de duas mãos entrelaçadas (uma adulta, uma infantil).
struct HandsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Mão adulta (maior, à esquerda)
        path.move(to: CGPoint(x: w * 0.25, y: h * 0.85))
        // Base da mão
        path.addCurve(
            to: CGPoint(x: w * 0.20, y: h * 0.55),
            control1: CGPoint(x: w * 0.18, y: h * 0.75),
            control2: CGPoint(x: w * 0.15, y: h * 0.65)
        )
        // Dedo mindinho
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.40))
        path.addCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.38),
            control1: CGPoint(x: w * 0.17, y: h * 0.37),
            control2: CGPoint(x: w * 0.20, y: h * 0.35)
        )
        path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.52))
        // Entre dedos
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.42))
        // Dedo anelar
        path.addLine(to: CGPoint(x: w * 0.26, y: h * 0.35))
        path.addCurve(
            to: CGPoint(x: w * 0.30, y: h * 0.33),
            control1: CGPoint(x: w * 0.25, y: h * 0.32),
            control2: CGPoint(x: w * 0.28, y: h * 0.30)
        )
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.48))
        // Entre dedos
        path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.38))
        // Dedo médio
        path.addLine(to: CGPoint(x: w * 0.34, y: h * 0.30))
        path.addCurve(
            to: CGPoint(x: w * 0.38, y: h * 0.28),
            control1: CGPoint(x: w * 0.33, y: h * 0.27),
            control2: CGPoint(x: w * 0.36, y: h * 0.25)
        )
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.45))
        // Entre dedos
        path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.35))
        // Dedo indicador
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.28))
        path.addCurve(
            to: CGPoint(x: w * 0.46, y: h * 0.26),
            control1: CGPoint(x: w * 0.41, y: h * 0.25),
            control2: CGPoint(x: w * 0.44, y: h * 0.23)
        )
        path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.50))
        // Polegar adulto
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.55),
            control1: CGPoint(x: w * 0.52, y: h * 0.48),
            control2: CGPoint(x: w * 0.58, y: h * 0.50)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.52, y: h * 0.62),
            control1: CGPoint(x: w * 0.58, y: h * 0.58),
            control2: CGPoint(x: w * 0.55, y: h * 0.62)
        )
        // Volta para base
        path.addCurve(
            to: CGPoint(x: w * 0.45, y: h * 0.85),
            control1: CGPoint(x: w * 0.55, y: h * 0.75),
            control2: CGPoint(x: w * 0.50, y: h * 0.82)
        )
        path.closeSubpath()

        // Mão infantil (menor, à direita, entrelaçada)
        path.move(to: CGPoint(x: w * 0.55, y: h * 0.80))
        path.addCurve(
            to: CGPoint(x: w * 0.58, y: h * 0.60),
            control1: CGPoint(x: w * 0.52, y: h * 0.72),
            control2: CGPoint(x: w * 0.55, y: h * 0.65)
        )
        // Dedos bebê
        path.addLine(to: CGPoint(x: w * 0.56, y: h * 0.50))
        path.addCurve(
            to: CGPoint(x: w * 0.60, y: h * 0.48),
            control1: CGPoint(x: w * 0.55, y: h * 0.47),
            control2: CGPoint(x: w * 0.58, y: h * 0.45)
        )
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.58))
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.48))
        path.addCurve(
            to: CGPoint(x: w * 0.68, y: h * 0.46),
            control1: CGPoint(x: w * 0.63, y: h * 0.45),
            control2: CGPoint(x: w * 0.66, y: h * 0.43)
        )
        path.addLine(to: CGPoint(x: w * 0.70, y: h * 0.56))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.46))
        path.addCurve(
            to: CGPoint(x: w * 0.76, y: h * 0.44),
            control1: CGPoint(x: w * 0.71, y: h * 0.43),
            control2: CGPoint(x: w * 0.74, y: h * 0.41)
        )
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.55))
        // Polegar bebê
        path.addCurve(
            to: CGPoint(x: w * 0.72, y: h * 0.62),
            control1: CGPoint(x: w * 0.78, y: h * 0.58),
            control2: CGPoint(x: w * 0.75, y: h * 0.62)
        )
        // Base
        path.addCurve(
            to: CGPoint(x: w * 0.65, y: h * 0.80),
            control1: CGPoint(x: w * 0.72, y: h * 0.72),
            control2: CGPoint(x: w * 0.68, y: h * 0.78)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    TogetherView(didComplete: .constant(false))
}
