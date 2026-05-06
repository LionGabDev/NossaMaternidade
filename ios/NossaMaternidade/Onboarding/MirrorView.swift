//
//  MirrorView.swift
//  NossaMaternidade
//

import SwiftUI
import AVFoundation

/// Tela 3: Espelho com câmera frontal.
/// Texto manuscrito da Nathalia aparece letra por letra.
struct MirrorView: View {
    @Binding var didComplete: Bool

    @State private var typedText = ""
    @State private var showContinueButton = false
    @State private var cameraAuthorized = false
    @State private var showCamera = true

    private let fullMessage = "eu também tive medo no começo.\n— nath"
    private let typingInterval = 0.08

    var body: some View {
        ZStack {
            // Câmera ou fundo de fallback
            if showCamera && cameraAuthorized {
                CameraPreviewView()
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [Color(hex: "#F4EDE4"), Color(hex: "#E8E2D6")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            // Vinheta nas bordas
            RadialGradient(
                colors: [.clear, Color(hex: "#F4EDE4").opacity(0.6)],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                Spacer()

                // Texto da Nathalia (typewriter effect)
                VStack(alignment: .leading, spacing: 8) {
                    Text(typedText)
                        .font(.system(.title3, design: .serif).italic())
                        .foregroundStyle(Color(hex: "#1A1A1A"))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)

                // Botão continuar
                if showContinueButton {
                    Button {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            didComplete = true
                        }
                    } label: {
                        Text("continuar")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#E8A598"))
                            .clipShape(.rect(cornerRadius: 24))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .padding(.bottom, 50)
                } else {
                    // Espaço reservado para não pular layout
                    Color.clear
                        .frame(height: 44)
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            checkCameraPermission()
            startTyping()
        }
    }

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    cameraAuthorized = granted
                }
            }
        default:
            cameraAuthorized = false
        }
    }

    private func startTyping() {
        typedText = ""
        let characters = Array(fullMessage)
        for (index, char) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * typingInterval) {
                typedText.append(char)
                // Haptic sutil a cada letra
                if index % 3 == 0 {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.3)
                }

                if index == characters.count - 1 {
                    withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                        showContinueButton = true
                    }
                }
            }
        }
    }
}

/// View que mostra o feed da câmera frontal usando AVCaptureVideoPreviewLayer.
struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return view
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        // Armazena a sessão para parar depois
        context.coordinator.session = session

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var session: AVCaptureSession?
    }
}

#Preview {
    MirrorView(didComplete: .constant(false))
}
