//
//  TimelineView.swift
//  NossaMaternidade
//

import SwiftUI

/// Tela 2: Timeline vertical interativa dos 9 meses.
/// A usuária arrasta o dedo para cima, passando pelos meses da gestação.
struct TimelineView: View {
    @Binding var didComplete: Bool

    @AppStorage("gestationMonth") private var savedGestationMonth: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var dragProgress: CGFloat = 0
    @State private var filledMonths: Set<Int> = []

    private let months = [
        (number: 1, label: "célula", icon: "circle.fill"),
        (number: 2, label: "semente", icon: "leaf.fill"),
        (number: 3, label: "feijão", icon: "capsule.fill"),
        (number: 4, label: "primeiro chute", icon: "hand.tap.fill"),
        (number: 5, label: "pezinho", icon: "footprint.fill"),
        (number: 6, label: "ouvindo", icon: "ear.fill"),
        (number: 7, label: "bebê posicionado", icon: "figure.stand"),
        (number: 8, label: "quase lá", icon: "heart.fill"),
        (number: 9, label: "berço", icon: "bed.double.fill")
    ]

    var body: some View {
        ZStack {
            // Fundo areia
            Color(hex: "#F4EDE4")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("em que mês você está?")
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(Color(hex: "#1A1A1A"))
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                GeometryReader { geometry in
                    let totalHeight = geometry.size.height
                    let stepHeight = totalHeight / CGFloat(months.count)

                    ZStack {
                        // Linha vertical base
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "#E8A598").opacity(0.2))
                            .frame(width: 4)

                        // Linha preenchida
                        VStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "#E8A598"))
                                .frame(width: 4, height: max(0, dragProgress * totalHeight))
                            Spacer()
                        }

                        // Círculos dos meses
                        VStack(spacing: 0) {
                            ForEach(0..<months.count, id: \.self) { index in
                                let month = months[index]
                                let isFilled = filledMonths.contains(index) || index == selectedMonth
                                let isCurrent = index == selectedMonth

                                HStack(spacing: 20) {
                                    // Círculo na linha
                                    ZStack {
                                        Circle()
                                            .fill(isFilled ? Color(hex: "#E8A598") : Color(hex: "#E8A598").opacity(0.2))
                                            .frame(width: isCurrent ? 28 : 20, height: isCurrent ? 28 : 20)
                                            .animation(.spring(response: 0.3), value: isCurrent)

                                        if isFilled {
                                            Text("\(month.number)")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                        }
                                    }

                                    // Ícone e label
                                    HStack(spacing: 10) {
                                        Image(systemName: month.icon)
                                            .font(.system(size: 16))
                                            .foregroundStyle(isFilled ? Color(hex: "#E8A598") : Color(hex: "#1A1A1A").opacity(0.3))
                                            .frame(width: 24)

                                        Text(month.label)
                                            .font(.system(size: 15, weight: isCurrent ? .semibold : .regular, design: .rounded))
                                            .foregroundStyle(isFilled ? Color(hex: "#1A1A1A") : Color(hex: "#1A1A1A").opacity(0.3))
                                    }
                                    .opacity(isFilled ? 1.0 : 0.5)

                                    Spacer()
                                }
                                .frame(height: stepHeight)
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let y = value.location.y
                                let progress = max(0, min(1, y / totalHeight))
                                dragProgress = progress

                                let currentIndex = min(months.count - 1, Int(progress * CGFloat(months.count)))
                                if currentIndex != selectedMonth {
                                    selectedMonth = currentIndex
                                    filledMonths.insert(currentIndex)
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                }
                            }
                            .onEnded { _ in
                                savedGestationMonth = selectedMonth + 1
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        didComplete = true
                                    }
                                }
                            }
                    )
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

#Preview {
    TimelineView(didComplete: .constant(false))
}
