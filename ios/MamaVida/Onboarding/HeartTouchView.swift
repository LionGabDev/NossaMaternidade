//
//  HeartTouchView.swift
//  MamaVida
//

import SwiftUI

/// Tela 1: O toque que pulsa.
/// A usuária segura o dedo na tela e sente um batimento cardíaco fetal.
struct HeartTouchView: View {
    @Binding var didComplete: Bool

    @State private var heartScale: CGFloat = 1.0
    @State private var isPressing = false
    @State private var showMessage = false
    @State private var glowOpacity: Double = 0.0
    @GestureState private var isLongPressing = false

    private let heartbeat = HapticHeartbeat.shared

    var body: some View {
        ZStack {
            // Fundo gradiente verde sálvia
            LinearGradient(
                colors: [
                    Color(hex: "#7A9E7E"),
                    Color(hex: "#5A7E5E")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Coração animado
                ZStack {
                    // Glow terracota
                    HeartShape()
                        .fill(Color(hex: "#E8A598").opacity(glowOpacity))
                        .scaleEffect(isPressing ? 1.4 : heartScale)
                        .blur(radius: isPressing ? 30 : 0)

                    HeartShape()
                        .fill(Color.white.opacity(0.95))
                        .scaleEffect(isPressing ? 1.4 : heartScale)
                        .shadow(
                            color: Color(hex: "#E8A598").opacity(isPressing ? 0.6 : 0.2),
                            radius: isPressing ? 40 : 20,
                            x: 0,
                            y: isPressing ? 10 : 5
                        )
                }
                .frame(width: 160, height: 160)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        heartScale = 1.15
                    }
                }

                // Texto sutil
                VStack(spacing: 16) {
                    Text("toque e segure")
                        .font(.system(size: 18, weight: .thin, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .opacity(showMessage ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: showMessage)

                    Text("oi, mãe")
                        .font(.system(.title, design: .serif).italic())
                        .foregroundStyle(.white)
                        .opacity(showMessage ? 1 : 0)
                        .offset(y: showMessage ? 0 : 10)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: showMessage)
                }

                Spacer()
            }
            .padding(.vertical, 60)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 3.0)
                .updating($isLongPressing) { value, state, _ in
                    state = value
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showMessage = true
                    }
                    heartbeat.stopHeartbeat()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            didComplete = true
                        }
                    }
                }
        )
        .onChange(of: isLongPressing) { oldValue, newValue in
            isPressing = newValue
            if newValue {
                heartbeat.startHeartbeat()
                withAnimation(.easeInOut(duration: 1.0)) {
                    glowOpacity = 0.8
                }
            } else {
                heartbeat.stopHeartbeat()
                withAnimation(.easeInOut(duration: 0.5)) {
                    glowOpacity = 0.0
                }
            }
        }
    }
}

/// Shape de coração desenhado com Path.
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scale: CGFloat = min(rect.width, rect.height) / 200
        let offsetX = rect.midX - 100 * scale
        let offsetY = rect.midY - 100 * scale

        path.move(to: CGPoint(x: 100 * scale + offsetX, y: 40 * scale + offsetY))

        path.addCurve(
            to: CGPoint(x: 20 * scale + offsetX, y: 100 * scale + offsetY),
            control1: CGPoint(x: 100 * scale + offsetX, y: -20 * scale + offsetY),
            control2: CGPoint(x: 0 * scale + offsetX, y: 20 * scale + offsetY)
        )

        path.addCurve(
            to: CGPoint(x: 100 * scale + offsetX, y: 180 * scale + offsetY),
            control1: CGPoint(x: 0 * scale + offsetX, y: 140 * scale + offsetY),
            control2: CGPoint(x: 70 * scale + offsetX, y: 170 * scale + offsetY)
        )

        path.addCurve(
            to: CGPoint(x: 180 * scale + offsetX, y: 100 * scale + offsetY),
            control1: CGPoint(x: 130 * scale + offsetX, y: 170 * scale + offsetY),
            control2: CGPoint(x: 200 * scale + offsetX, y: 140 * scale + offsetY)
        )

        path.addCurve(
            to: CGPoint(x: 100 * scale + offsetX, y: 40 * scale + offsetY),
            control1: CGPoint(x: 200 * scale + offsetX, y: 20 * scale + offsetY),
            control2: CGPoint(x: 100 * scale + offsetX, y: -20 * scale + offsetY)
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    HeartTouchView(didComplete: .constant(false))
}
