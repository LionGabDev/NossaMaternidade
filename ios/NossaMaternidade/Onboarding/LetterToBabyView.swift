//
//  LetterToBabyView.swift
//  NossaMaternidade
//

import SwiftUI
import AVFoundation

/// Tela 4: Carta para o bebê.
/// A usuária grava 5 segundos de áudio para o bebê.
struct LetterToBabyView: View {
    @Binding var didComplete: Bool

    @AppStorage("letterToBabyURL") private var savedRecordingURL: String = ""
    @State private var isRecording = false
    @State private var progress: CGFloat = 0.0
    @State private var showSkip = true
    @State private var particles: [Particle] = []

    private let maxDuration: CGFloat = 5.0

    var body: some View {
        ZStack {
            // Fundo carvão com partículas
            Color(hex: "#1A1A1A")
                .ignoresSafeArea()

            // Partículas flutuantes
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: true),
                        value: particle.opacity
                    )
            }

            VStack(spacing: 40) {
                Spacer()

                Text("grave 5 segundos\npara seu bebê")
                    .font(.system(.title2, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                // Botão circular de gravação
                ZStack {
                    // Círculo de progresso
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color(hex: "#E8A598"), lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 120, height: 120)

                    // Botão principal
                    Button {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.white : Color(hex: "#E8A598"))
                                .frame(width: 100, height: 100)

                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(isRecording ? Color(hex: "#E8A598") : .white)
                        }
                    }
                    .disabled(isRecording && progress < 1.0)
                }

                // Timer
                Text(isRecording ? String(format: "%.1fs", progress * maxDuration) : "toque para gravar")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                // Botão pular
                if showSkip {
                    Button {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            didComplete = true
                        }
                    } label: {
                        Text("pular")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            generateParticles()
            requestMicrophonePermission()
        }
    }

    private func generateParticles() {
        for _ in 0..<20 {
            let particle = Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.1...0.4),
                duration: Double.random(in: 2...5)
            )
            particles.append(particle)
        }
    }

    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            return
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("letterToBaby.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.record(forDuration: TimeInterval(maxDuration))

            isRecording = true
            progress = 0.0
            showSkip = false

            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // Anima o progresso
            withAnimation(.linear(duration: TimeInterval(maxDuration))) {
                progress = 1.0
            }

            // Para após 5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration) {
                if self.isRecording {
                    self.stopRecording()
                }
            }
        } catch {
            print("Erro ao iniciar gravação: \(error)")
        }
    }

    private func stopRecording() {
        isRecording = false
        progress = 0.0
        showSkip = true

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.6)) {
                didComplete = true
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var duration: Double
}

#Preview {
    LetterToBabyView(didComplete: .constant(false))
}
