//
//  Content-ViewModel.swift
//  PowerLift
//
//  Created by Kevin Atapattu on 2024-08-01.
//

import Foundation
import UserNotifications
import Combine

extension ContentView {
    final class ViewModel: ObservableObject {
        @Published var isActive = false
        @Published var isPaused = false
        @Published var showingAlert = false
        @Published var time: String = "5:00"
        @Published var progress: Double = 0.0 // 0.0 ... 1.0

        // Picker selections
        @Published var selectedHours: Int = 0 { didSet { updatePreviewTime() } }
        @Published var selectedMinutes: Int = 5 { didSet { updatePreviewTime() } }
        @Published var selectedSeconds: Int = 0 { didSet { updatePreviewTime() } }

        // Backing time values
        private var totalDurationSeconds: Int = 300
        private var remainingSeconds: Double = 300.0 // Changed to Double for smooth progress
        private var endDate = Date()
        private var notificationScheduled = false
        
        // MARK: - Public API
        func start() {
            applySelectionAsDuration()
            guard totalDurationSeconds > 0 else { return }

            isActive = true
            isPaused = false
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            scheduleEndNotificationIfNeeded()
        }

        func pause() {
            guard isActive, !isPaused else { return }
            isPaused = true
            // Capture remaining seconds at pause
            let now = Date()
            remainingSeconds = max(0, endDate.timeIntervalSince(now))
            cancelScheduledNotification()
        }

        func resume() {
            guard isActive, isPaused, remainingSeconds > 0 else { return }
            isPaused = false
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            scheduleEndNotificationIfNeeded()
        }
        
        func reset() {
            isActive = false
            isPaused = false
            cancelScheduledNotification()
            // Restore from current selection as preview
            applySelectionAsDuration()
            updatePreviewTime()
        }
        
        func updateCountdown() {
            guard isActive else { return }
            guard !isPaused else { return }
            
            let now = Date()
            let difference = endDate.timeIntervalSince(now)
            
            if difference <= 0 {
                isActive = false
                isPaused = false
                remainingSeconds = 0
                time = formatTime(from: 0)
                progress = 1.0
                showingAlert = true
                recordRecent(durationSeconds: totalDurationSeconds)
                cancelScheduledNotification()
                return
            }
            
            remainingSeconds = max(0, difference)
            time = formatTime(from: Int(remainingSeconds.rounded()))
            progress = 1.0 - (remainingSeconds / Double(max(totalDurationSeconds, 1)))
        }
        
        private func formatTime(from totalSeconds: Int) -> String {
            if totalSeconds >= 3600 {
                let hours = totalSeconds / 3600
                let minutes = (totalSeconds % 3600) / 60
                let seconds = totalSeconds % 60
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                let minutes = totalSeconds / 60
                let seconds = totalSeconds % 60
                return String(format: "%d:%02d", minutes, seconds)
            }
        }

        private func applySelectionAsDuration() {
            totalDurationSeconds = selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds
            remainingSeconds = Double(totalDurationSeconds)
        }

        private func updatePreviewTime() {
            applySelectionAsDuration()
            time = formatTime(from: totalDurationSeconds)
            progress = 0.0
        }

        // MARK: - Recents
        @Published var recentDurations: [Int] = [] // seconds

        init() {
            loadRecents()
            updatePreviewTime()
        }

        private func recordRecent(durationSeconds: Int) {
            guard durationSeconds > 0 else { return }
            var updated = recentDurations
            updated.removeAll { $0 == durationSeconds }
            updated.insert(durationSeconds, at: 0)
            if updated.count > 5 { updated = Array(updated.prefix(5)) }
            recentDurations = updated
            saveRecents()
        }

        private func saveRecents() {
            UserDefaults.standard.set(recentDurations, forKey: "timer_recents")
        }

        private func loadRecents() {
            if let array = UserDefaults.standard.array(forKey: "timer_recents") as? [Int] {
                recentDurations = array
            }
        }

        // MARK: - Notifications
        private func scheduleEndNotificationIfNeeded() {
            guard remainingSeconds > 0 else { return }
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }

            let content = UNNotificationContent()
            let mutable = UNMutableNotificationContent()
            mutable.title = "Timer Finished"
            mutable.body = "Your countdown has ended."
            mutable.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remainingSeconds), repeats: false)
            let request = UNNotificationRequest(identifier: "powerlift_timer_end", content: mutable, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
            notificationScheduled = true
        }

        private func cancelScheduledNotification() {
            if notificationScheduled {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["powerlift_timer_end"])
                notificationScheduled = false
            }
        }
    }
    

}
