//
//  RestTimerNotification.swift
//  WorkoutTimer
//

import Foundation
import UserNotifications

enum RestTimerNotification {
    private static var currentRequestID: String?

    static func schedule(
        endDate: Date,
        message: String,
        soundEnabled: Bool
    ) {
        cancel()

        let delay = endDate.timeIntervalSinceNow
        guard delay > 0 else { return }

        let requestID = "rest-timer-\(UUID().uuidString)"
        currentRequestID = requestID

        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                do {
                    let allowed = try await center.requestAuthorization(
                        options: [.alert, .sound]
                    )
                    guard allowed else { return }
                } catch {
                    return
                }
            case .authorized, .provisional, .ephemeral:
                break
            case .denied:
                return
            @unknown default:
                return
            }

            guard currentRequestID == requestID else { return }

            let remainingDelay = endDate.timeIntervalSinceNow
            guard remainingDelay > 0 else { return }

            let content = UNMutableNotificationContent()
            content.title = "Rest complete"
            content.body = message
            content.sound = soundEnabled ? .default : nil

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: remainingDelay,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: requestID,
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    static func cancel() {
        guard let currentRequestID else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: [currentRequestID]
        )
        center.removeDeliveredNotifications(
            withIdentifiers: [currentRequestID]
        )
        self.currentRequestID = nil
    }
}
