//
//  HapticHeartbeat.swift
//  MamaVida
//

import CoreHaptics
import SwiftUI

/// Utilitário que reproduz padrões hápticos simulando um batimento cardíaco fetal (~122 bpm).
@MainActor
final class HapticHeartbeat {
    static let shared = HapticHeartbeat()
    private var engine: CHHapticEngine?
    private var timer: Timer?

    private init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Falha ao iniciar CHHapticEngine: \(error)")
        }
    }

    /// Inicia o batimento contínuo em loop (~122 bpm = ~491ms entre batidas).
    func startHeartbeat() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        stopHeartbeat()
        do {
            try engine?.start()
        } catch { }

        let interval = 0.491
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.triggerSingleBeat()
        }
        triggerSingleBeat()
    }

    /// Para o batimento.
    func stopHeartbeat() {
        timer?.invalidate()
        timer = nil
        engine?.stop(completionHandler: nil)
    }

    private func triggerSingleBeat() {
        guard let engine = engine else { return }

        // Pattern: dois pulsos curtos ("lub-dub")
        var events: [CHHapticEvent] = []

        let intensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
        let sharpness1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
        events.append(CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity1, sharpness1],
            relativeTime: 0.0
        ))

        let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        events.append(CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity2, sharpness2],
            relativeTime: 0.12
        ))

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Erro ao tocar haptic: \(error)")
        }
    }
}
