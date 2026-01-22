//
//  NotificationManager.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notifications: [AppNotification] = []
    
    private let notificationsKey = "savedNotifications"
    
    init() {
        loadNotifications()
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(for project: Project) {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate days until event
        let components = calendar.dateComponents([.day], from: now, to: project.eventDate)
        guard let daysLeft = components.day, daysLeft >= 0 else { return }
        
        // Schedule notifications for 7, 3, and 1 days before, and on the day
        let notificationDays = [7, 3, 1, 0]
        
        for days in notificationDays {
            if daysLeft >= days {
                scheduleNotification(for: project, daysBeforeEvent: days)
            }
        }
    }
    
    private func scheduleNotification(for project: Project, daysBeforeEvent: Int) {
        let calendar = Calendar.current
        guard let notificationDate = calendar.date(byAdding: .day, value: -daysBeforeEvent, to: project.eventDate) else { return }
        
        // Only schedule if notification date is in the future
        guard notificationDate > Date() else {
            // If date is today or past, add notification to list immediately
            if calendar.isDateInToday(notificationDate) || notificationDate < Date() {
                addNotificationToList(for: project, daysLeft: daysBeforeEvent)
            }
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Cosplay Reminder"
        
        if daysBeforeEvent == 0 {
            content.body = "Today is the day! \(project.eventName) is happening now!"
        } else if daysBeforeEvent == 1 {
            content.body = "The final fitting! \(project.eventName) is in 1 day"
        } else {
            content.body = "Get ready! \(project.eventName) is in \(daysBeforeEvent) days"
        }
        
        content.sound = .default
        
        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = "\(project.id.uuidString)-\(daysBeforeEvent)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(project.eventName) - \(daysBeforeEvent) days before")
            }
        }
    }
    
    func addNotificationToList(for project: Project, daysLeft: Int) {
        let notification = AppNotification(
            projectId: project.id,
            projectName: project.projectName,
            eventName: project.eventName,
            daysLeft: daysLeft,
            date: Date()
        )
        
        DispatchQueue.main.async {
            // Check if notification already exists
            if !self.notifications.contains(where: { $0.projectId == project.id && $0.daysLeft == daysLeft }) {
                self.notifications.insert(notification, at: 0)
                self.saveNotifications()
            }
        }
    }
    
    func cancelNotifications(for projectId: UUID) {
        let identifiers = [0, 1, 3, 7].map { "\(projectId.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func deleteNotification(_ notification: AppNotification) {
        notifications.removeAll { $0.id == notification.id }
        saveNotifications()
    }
    
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            saveNotifications()
        }
    }
    
    func checkAndAddDueNotifications() {
        let projects = ProjectManager.shared.projects
        let calendar = Calendar.current
        let now = Date()
        
        for project in projects {
            let components = calendar.dateComponents([.day], from: now, to: project.eventDate)
            if let daysLeft = components.day {
                // Add notifications for upcoming events
                if daysLeft == 7 || daysLeft == 3 || daysLeft == 1 || daysLeft == 0 {
                    addNotificationToList(for: project, daysLeft: max(0, daysLeft))
                }
            }
        }
    }
    
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: notificationsKey)
        }
    }
    
    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: notificationsKey),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) {
            notifications = decoded
        }
    }
}
