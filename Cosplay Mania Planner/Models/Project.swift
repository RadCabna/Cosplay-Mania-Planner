//
//  Project.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

struct Project: Identifiable, Codable {
    var id = UUID()
    var projectName: String
    var source: String
    var eventName: String
    var budget: String
    var eventDate: Date
    var imageData: Data?
    var status: ProjectFilter = .active
    var expenses: [Expense] = []
    var tasks: [ChecklistTask] = []
    
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    var totalBudget: Double {
        return Double(budget) ?? 0.0
    }
    
    var totalSpent: Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBudget: Double {
        return totalBudget - totalSpent
    }
    
    var completedTasksCount: Int {
        return tasks.filter { $0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard !tasks.isEmpty else { return 0.0 }
        return Double(completedTasksCount) / Double(tasks.count) * 100
    }
    
    var daysLeft: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: eventDate)
        return max(components.day ?? 0, 0)
    }
}
