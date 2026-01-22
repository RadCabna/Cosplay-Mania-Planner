//
//  Expense.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import Foundation

enum ExpenseType: String, Codable, CaseIterable {
    case fabricOutfit = "Fabric & Outfit"
    case wigHair = "Wig & Hair"
    case designPaint = "Design & Paint"
    case other = "Other"
    
    var iconName: String {
        switch self {
        case .fabricOutfit: return "tag_1"
        case .wigHair: return "tag_2"
        case .designPaint: return "tag_3"
        case .other: return "tag_4"
        }
    }
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var store: String
    var item: String
    var amount: Double
    var type: ExpenseType
    var date: Date // Дата добавления траты
    
    init(id: UUID = UUID(), store: String, item: String, amount: Double, type: ExpenseType, date: Date = Date()) {
        self.id = id
        self.store = store
        self.item = item
        self.amount = amount
        self.type = type
        self.date = date
    }
}
