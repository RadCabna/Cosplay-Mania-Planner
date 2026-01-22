//
//  Task.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import Foundation

struct ChecklistTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}
