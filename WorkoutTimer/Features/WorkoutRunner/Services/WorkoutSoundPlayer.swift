//
//  WorkoutSoundPlayer.swift
//  WorkoutTimer
//

import AVFAudio
import Foundation

final class WorkoutSoundPlayer {
    static let shared = WorkoutSoundPlayer()

    private struct Pulse {
        let frequency: Double
        let startTime: Double
        let duration: Double
        let amplitude: Float
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate = 44_100.0
    private let format: AVAudioFormat

    private init() {
        format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )!

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    func playCountdownTick() {
        play(
            pulses: [
                Pulse(
                    frequency: 2_200,
                    startTime: 0,
                    duration: 0.045,
                    amplitude: 0.8
                )
            ],
            totalDuration: 0.05
        )
    }

    func playRestComplete() {
        play(
            pulses: [
                Pulse(
                    frequency: 1_600,
                    startTime: 0,
                    duration: 0.06,
                    amplitude: 0.8
                ),
                Pulse(
                    frequency: 2_400,
                    startTime: 0.085,
                    duration: 0.075,
                    amplitude: 0.85
                )
            ],
            totalDuration: 0.17
        )
    }

    private func play(pulses: [Pulse], totalDuration: Double) {
        guard let buffer = makeBuffer(pulses: pulses, duration: totalDuration) else {
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, options: .mixWithOthers)
            try audioSession.setActive(true)

            if !engine.isRunning {
                try engine.start()
            }

            player.stop()
            player.scheduleBuffer(buffer)
            player.play()
        } catch {
            // Sound is supplementary; timer progression should never depend on it.
        }
    }

    private func makeBuffer(
        pulses: [Pulse],
        duration: Double
    ) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ), let samples = buffer.floatChannelData?[0] else {
            return nil
        }

        buffer.frameLength = frameCount

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            var sample: Float = 0

            for pulse in pulses {
                let localTime = time - pulse.startTime
                guard localTime >= 0, localTime < pulse.duration else { continue }

                let attack = min(localTime / 0.002, 1)
                let decay = exp(-8 * localTime / pulse.duration)
                let wave = sin(2 * Double.pi * pulse.frequency * localTime)
                sample += Float(wave * attack * decay) * pulse.amplitude
            }

            samples[frame] = min(max(sample, -1), 1)
        }

        return buffer
    }
}
