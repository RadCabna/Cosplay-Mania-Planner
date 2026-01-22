//
//  AppNotification.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import Foundation

struct AppNotification: Identifiable, Codable {
    var id = UUID()
    var projectId: UUID
    var projectName: String
    var eventName: String
    var daysLeft: Int
    var date: Date
    var isRead: Bool = false
    
    var message: String {
        if daysLeft == 0 {
            return "Today is the day! \(eventName) is happening now!"
        } else if daysLeft == 1 {
            return "The final fitting! \(eventName) is in 1 day"
        } else {
            return "Get ready! \(eventName) is in \(daysLeft) days"
        }
    }
}
