//
//  Statistic.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

enum StatisticTab: String, CaseIterable {
    case general = "General"
    case projects = "Projects"
}

struct Statistic: View {
    @ObservedObject private var projectManager = ProjectManager.shared
    @State private var selectedTab: StatisticTab = .general
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Statistic")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.028))
                    .foregroundColor(Color("text_1Color"))
                    .padding(.top, screenHeight * 0.025)
                    .padding(.bottom, screenHeight * 0.02)
                
                // Tab selector
                HStack(spacing: screenWidth * 0.02) {
                    ForEach(StatisticTab.allCases, id: \.self) { tab in
                        StatisticTabButton(
                            title: tab.rawValue,
                            isSelected: selectedTab == tab,
                            animation: animation
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
                .padding(.horizontal, screenWidth * 0.015)
                .padding(.vertical, screenHeight * 0.004)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.018)
                        .fill(Color.white.opacity(0.3))
                )
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.bottom, screenHeight * 0.02)
                
                // Content
                ScrollView {
                    VStack(spacing: screenHeight * 0.02) {
                        if selectedTab == .general {
                            GeneralStatsView()
                        } else {
                            ProjectsStatsView()
                        }
                    }
                    .padding(.bottom, screenHeight * 0.02)
                }
            }
        }
    }
}

struct StatisticTabButton: View {
    let title: String
    let isSelected: Bool
    var animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                .foregroundColor(Color("text_1Color"))
                .padding(.horizontal, screenWidth * 0.08)
                .padding(.vertical, screenHeight * 0.01)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                                .fill(Color.white)
                                .matchedGeometryEffect(id: "STAT_TAB", in: animation)
                        }
                    }
                )
        }
    }
}

struct GeneralStatsView: View {
    @ObservedObject private var projectManager = ProjectManager.shared
    
    private var totalSpend: Double {
        projectManager.projects.reduce(0) { $0 + $1.totalSpent }
    }
    
    private var totalBudget: Double {
        projectManager.projects.reduce(0) { sum, project in
            sum + (Double(project.budget) ?? 0)
        }
    }
    
    private var projectCount: Int {
        projectManager.projects.count
    }
    
    private var budgetChangeText: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Current month budget (projects created this month)
        let currentMonthBudget = projectManager.projects.filter { project in
            calendar.isDate(project.eventDate, equalTo: now, toGranularity: .month)
        }.reduce(0.0) { sum, project in
            sum + (Double(project.budget) ?? 0)
        }
        
        // Last month budget
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
            return "+100% vs last month"
        }
        
        let lastMonthBudget = projectManager.projects.filter { project in
            calendar.isDate(project.eventDate, equalTo: lastMonth, toGranularity: .month)
        }.reduce(0.0) { sum, project in
            sum + (Double(project.budget) ?? 0)
        }
        
        // Calculate percentage change
        if lastMonthBudget == 0 {
            return currentMonthBudget > 0 ? "+100% vs last month" : "No change"
        }
        
        let change = ((currentMonthBudget - lastMonthBudget) / lastMonthBudget) * 100
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.0f", change))% vs last month"
    }
    
    private var categorySpending: [(category: String, amount: Double, color: String)] {
        var fabric: Double = 0
        var wigs: Double = 0
        var design: Double = 0
        
        for project in projectManager.projects {
            for expense in project.expenses {
                switch expense.type {
                case .fabricOutfit:
                    fabric += expense.amount
                case .wigHair:
                    wigs += expense.amount
                case .designPaint:
                    design += expense.amount
                case .other:
                    break
                }
            }
        }
        
        return [
            ("Fabric", fabric, "diagram_1"),
            ("Wigs", wigs, "diagram_2"),
            ("Design", design, "diagram_3")
        ]
    }
    
    private var monthlySpending: [(month: String, amount: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [Int: (String, Double)] = [:]
        
        // Initialize 6 months
        for i in (0..<6).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            let monthName = monthFormatter.string(from: monthDate).uppercased()
            
            let monthKey = calendar.component(.month, from: monthDate) + calendar.component(.year, from: monthDate) * 100
            monthlyData[monthKey] = (monthName, 0)
        }
        
        // Group expenses by their actual date
        for project in projectManager.projects {
            for expense in project.expenses {
                let expenseMonth = calendar.component(.month, from: expense.date)
                let expenseYear = calendar.component(.year, from: expense.date)
                let monthKey = expenseMonth + expenseYear * 100
                
                if var existing = monthlyData[monthKey] {
                    existing.1 += expense.amount
                    monthlyData[monthKey] = existing
                }
            }
        }
        
        // Convert back to sorted array
        let sortedKeys = monthlyData.keys.sorted()
        return sortedKeys.compactMap { monthlyData[$0] }
    }
    
    private var peakMonth: (month: String, amount: Double) {
        let spending = monthlySpending
        guard let peak = spending.max(by: { $0.amount < $1.amount }) else {
            return ("", 0)
        }
        return peak
    }
    
    private var averageMonthly: Double {
        let spending = monthlySpending
        guard !spending.isEmpty else { return 0 }
        let total = spending.reduce(0) { $0 + $1.amount }
        return total / Double(spending.count)
    }
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Total cards
            HStack(spacing: screenWidth * 0.04) {
                // Total Spend
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    HStack(spacing: screenWidth * 0.02) {
                        Image("statSpend")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                        
                        Text("Total Spend")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color"))
                    }
                    
                    Text(projectCount > 0 ? "$\(String(format: "%.0f", totalSpend))" : "???????")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.03))
                        .foregroundColor(Color("text_1Color"))
                        .padding(.vertical, screenHeight * 0.005)
                    
                    Text(projectCount > 0 ? "Across \(projectCount) projects" : "???????")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                        .foregroundColor(Color("text_3Color"))
                }
                .padding(screenWidth * 0.04)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.025)
                        .stroke(Color("text_3Color"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.025)
                                .fill(Color("bgColor"))
                        )
                )
                
                // Total Budget
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    HStack(spacing: screenWidth * 0.02) {
                        Image("statBudget")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                        
                        Text("Total Budget")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color"))
                    }
                    
                    Text(projectCount > 0 ? "$\(String(format: "%.0f", totalBudget))" : "???????")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.03))
                        .foregroundColor(Color("text_1Color"))
                        .padding(.vertical, screenHeight * 0.005)
                    
                    Text(projectCount > 0 ? budgetChangeText : "???????")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                        .foregroundColor(Color("text_2Color"))
                }
                .padding(screenWidth * 0.04)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.025)
                        .stroke(Color("text_2Color"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.025)
                                .fill(Color("bgColor"))
                        )
                )
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Category Distribution
            VStack(alignment: .leading, spacing: screenHeight * 0.02) {
                HStack(spacing: screenWidth * 0.02) {
                    Image("diagramIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                    
                    Text("Category Distribution")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                        .foregroundColor(Color("text_1Color"))
                }
                
                // Donut chart
                DonutChartView(data: categorySpending)
                    .frame(height: screenHeight * 0.25)
                    .padding(.vertical, screenHeight * 0.02)
                
                // Legend
                HStack(spacing: screenWidth * 0.04) {
                    ForEach(categorySpending, id: \.category) { item in
                        VStack(spacing: screenHeight * 0.008) {
                            HStack(spacing: screenWidth * 0.02) {
                                Circle()
                                    .fill(Color(item.color))
                                    .frame(width: screenHeight * 0.015, height: screenHeight * 0.015)
                                
                                Text(item.category)
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                                    .foregroundColor(Color("text_1Color"))
                            }
                            
                            Text("$\(String(format: "%.0f", item.amount))")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                .foregroundColor(Color("text_1Color"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(screenWidth * 0.04)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.025)
                    .fill(Color.white)
            )
            .padding(.horizontal, screenWidth * 0.05)
            
            // Monthly Spending
            VStack(alignment: .leading, spacing: screenHeight * 0.02) {
                HStack(spacing: screenWidth * 0.02) {
                    Image("diagramIcon2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                    
                    Text("Monthly Spending")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                        .foregroundColor(Color("text_1Color"))
                }
                
                // Bar chart
                BarChartView(data: monthlySpending)
                    .frame(height: screenHeight * 0.25)
                    .padding(.vertical, screenHeight * 0.02)
                
                // Divider
                Rectangle()
                    .fill(Color("text_1Color").opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, screenWidth * 0.02)
                
                // Stats
                HStack {
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        Text("Peak Month")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color("text_1Color").opacity(0.7))
                        
                        Text("\(peakMonth.month) ($\(String(format: "%.0f", peakMonth.amount)))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                            .foregroundColor(Color("text_1Color"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: screenHeight * 0.005) {
                        Text("Avg. Monthly")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color("text_1Color").opacity(0.7))
                        
                        Text("$\(String(format: "%.2f", averageMonthly))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                            .foregroundColor(Color("text_1Color"))
                    }
                }
                .padding(.top, screenHeight * 0.01)
            }
            .padding(screenWidth * 0.04)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.025)
                    .fill(Color.white)
            )
            .padding(.horizontal, screenWidth * 0.05)
        }
    }
}

struct DonutChartView: View {
    let data: [(category: String, amount: Double, color: String)]
    
    private var total: Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if total == 0 {
                    // Empty state
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: screenHeight * 0.04)
                } else {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        if item.amount > 0 {
                            DonutSlice(
                                startPercent: startPercent(for: index),
                                endPercent: endPercent(for: index),
                                color: Color(item.color)
                            )
                        }
                    }
                }
            }
            .frame(width: min(geometry.size.width, geometry.size.height),
                   height: min(geometry.size.width, geometry.size.height))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func startPercent(for index: Int) -> Double {
        let previousSum = data.prefix(index).reduce(0) { $0 + $1.amount }
        return previousSum / total
    }
    
    private func endPercent(for index: Int) -> Double {
        let currentSum = data.prefix(index + 1).reduce(0) { $0 + $1.amount }
        return currentSum / total
    }
}

struct DonutSlice: View {
    let startPercent: Double
    let endPercent: Double
    let color: Color
    
    var body: some View {
        Circle()
            .trim(from: startPercent, to: endPercent)
            .stroke(color, style: StrokeStyle(lineWidth: screenHeight * 0.04, lineCap: .butt))
            .rotationEffect(.degrees(-90))
    }
}

struct BarChartView: View {
    let data: [(month: String, amount: Double)]
    
    private var maxAmount: Double {
        let max = data.map { $0.amount }.max() ?? 0
        return ceil(max / 100) * 100
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                // Y-axis labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach((0...Int(maxAmount / 100)).reversed(), id: \.self) { tick in
                        Text("\(tick * 100)")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.014))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                            .frame(height: geometry.size.height / CGFloat(Int(maxAmount / 100) + 1))
                    }
                }
                .frame(width: screenWidth * 0.1)
                
                // Bars
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        if index > 0 {
                            Spacer()
                        }
                        
                        VStack(spacing: screenHeight * 0.008) {
                            RoundedRectangle(cornerRadius: screenHeight * 0.006)
                                .fill(Color("part_1Color"))
                                .frame(width: screenWidth * 0.04, height: max(geometry.size.height * 0.9 * CGFloat(item.amount / maxAmount), 2))
                            
                            Text(item.month)
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.014))
                                .foregroundColor(Color("text_1Color").opacity(0.6))
                        }
                    }
                }
            }
        }
    }
}

struct ProjectsStatsView: View {
    @ObservedObject private var projectManager = ProjectManager.shared
    
    var allProjects: [Project] {
        projectManager.projects + projectManager.archivedProjects
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: screenHeight * 0.015) {
                if allProjects.isEmpty {
                    VStack(spacing: screenHeight * 0.02) {
                        Image("notYetIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.06, height: screenHeight * 0.06)
                        
                        Text("No projects yet")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.024))
                            .foregroundColor(Color("text_1Color"))
                        
                        Text("Start creating projects\nto see statistics")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, screenHeight * 0.1)
                } else {
                    ForEach(allProjects) { project in
                        ProjectStatsCard(
                            project: project,
                            isArchived: projectManager.archivedProjects.contains(where: { $0.id == project.id })
                        )
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            .padding(.vertical, screenHeight * 0.02)
        }
    }
}

struct ProjectStatsCard: View {
    let project: Project
    let isArchived: Bool
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                HStack {
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        HStack(spacing: screenWidth * 0.02) {
                            Text(project.projectName)
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                                .foregroundColor(Color("text_1Color"))
                            
                            if isArchived {
                                Text("ARCHIVED")
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.012))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, screenWidth * 0.02)
                                    .padding(.vertical, screenHeight * 0.003)
                                    .background(
                                        RoundedRectangle(cornerRadius: screenHeight * 0.006)
                                            .fill(Color.red.opacity(0.7))
                                    )
                            }
                        }
                        
                        Text(project.eventName)
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                    }
                    
                    Spacer()
                    
                    if let image = project.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenHeight * 0.06, height: screenHeight * 0.06)
                            .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.015))
                    }
                }
                
                Divider()
                
                HStack(spacing: screenWidth * 0.06) {
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        Text("Budget")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.014))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                        Text("$\(project.budget)")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color"))
                    }
                    
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        Text("Spent")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.014))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                        Text("$\(String(format: "%.0f", project.totalSpent))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color"))
                    }
                    
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        Text("Progress")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.014))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                        Text("\(Int(project.completionPercentage))%")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color"))
                    }
                    
                    Spacer()
                }
            }
            .padding(screenWidth * 0.04)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.02)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: screenHeight * 0.02)
                            .stroke(isArchived ? Color.red.opacity(0.3) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .fullScreenCover(isPresented: $showDetail) {
            ReadOnlyProjectDetailView(project: project, isArchived: isArchived)
        }
    }
}

struct ReadOnlyProjectDetailView: View {
    @Environment(\.dismiss) var dismiss
    let project: Project
    let isArchived: Bool
    @State private var selectedTab: ProjectDetailTab = .details
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("backButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.03)
                    }
                    
                    Spacer()
                    
                    Text(project.projectName)
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.028))
                        .foregroundColor(Color("text_1Color"))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isArchived {
                        Text("ARCHIVED")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.012))
                            .foregroundColor(.white)
                            .padding(.horizontal, screenWidth * 0.02)
                            .padding(.vertical, screenHeight * 0.005)
                            .background(
                                RoundedRectangle(cornerRadius: screenHeight * 0.008)
                                    .fill(Color.red.opacity(0.7))
                            )
                    } else {
                        Color.clear.frame(width: screenHeight * 0.03)
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.025)
                
                ScrollView {
                    VStack(spacing: screenHeight * 0.025) {
                        // Project Image with overlay
                        ZStack(alignment: .bottomLeading) {
                            if let image = project.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.35)
                                    .clipShape(RoundedRectangle(cornerRadius: screenHeight * 0.035))
                                    .clipped()
                            } else {
                                RoundedRectangle(cornerRadius: screenHeight * 0.035)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.35)
                            }
                            
                            // Status and event info overlay
                            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                                Image(project.status == .completed ? "doneIcon" : "inProgressIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight * 0.03)
                                
                                HStack(spacing: screenWidth * 0.02) {
                                    Image("calendarIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                                    
                                    Text(project.eventName)
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                        .foregroundColor(.white)
                                    
                                    Text("-")
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                        .foregroundColor(.white)
                                    
                                    Text(formattedDate(project.eventDate))
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, screenWidth * 0.03)
                                .padding(.vertical, screenHeight * 0.01)
                                .background(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.015)
                                        .fill(Color("text_1Color").opacity(0.3))
                                )
                            }
                            .padding(.leading, screenHeight * 0.02)
                            .padding(.bottom, screenHeight * 0.02)
                        }
                        .frame(width: screenWidth * 0.9)
                        
                        // Tab selector (same as original but read-only)
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ForEach(ProjectDetailTab.allCases, id: \.self) { tab in
                                    DetailTabButton(
                                        title: tab.rawValue,
                                        isSelected: selectedTab == tab,
                                        animation: animation
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedTab = tab
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, screenWidth * 0.05)
                            .padding(.vertical, screenHeight * 0.015)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.035)
                                .fill(Color("text_1Color").opacity(0.1))
                        )
                        .frame(width: screenWidth * 0.9)
                        
                        // Tab content (read-only views)
                        switch selectedTab {
                        case .details:
                            ReadOnlyDetailsView(project: project)
                        case .stages:
                            ReadOnlyStagesView(project: project)
                        case .budget:
                            ReadOnlyBudgetView(project: project)
                        }
                    }
                    .padding(.vertical, screenHeight * 0.02)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// Read-only views
struct ReadOnlyDetailsView: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            InfoRow(title: "Project name", value: project.projectName)
            InfoRow(title: "Source", value: project.source)
            InfoRow(title: "Event name", value: project.eventName)
            InfoRow(title: "Budget", value: "$\(project.budget)")
            InfoRow(title: "Event date", value: formattedDate(project.eventDate))
        }
        .padding(.horizontal, screenWidth * 0.05)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct ReadOnlyStagesView: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            // Competition Rate Card (same as original)
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                Text("COMPETITION RATE")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                    .foregroundColor(Color("text_1Color"))
                    .textCase(.uppercase)
                
                HStack {
                    Text("\(project.completedTasksCount)/\(project.tasks.count)")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                        .foregroundColor(Color("text_1Color"))
                    
                    Text("Stages done")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                        .foregroundColor(Color("text_1Color").opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(project.completionPercentage))%")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                        .foregroundColor(Color("text_1Color"))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: screenHeight * 0.01)
                            .fill(Color("part_1Color").opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: screenHeight * 0.01)
                            .fill(Color("part_1Color").opacity(0.3))
                            .frame(width: geometry.size.width * CGFloat(project.completionPercentage / 100))
                    }
                }
                .frame(height: screenHeight * 0.015)
                
                HStack(spacing: screenWidth * 0.03) {
                    HStack(spacing: screenWidth * 0.03) {
                        Image("timeIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                        
                        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                            Text("TIME LEFT")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                .foregroundColor(Color("text_2Color"))
                                .textCase(.uppercase)
                            
                            Text("\(project.daysLeft) days")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                .foregroundColor(Color("text_1Color"))
                        }
                    }
                    .padding(screenWidth * 0.03)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.035)
                            .fill(Color.gray.opacity(0.2))
                    )
                    
                    HStack(spacing: screenWidth * 0.03) {
                        Image("budgetMiniIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                        
                        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                            Text("BUDGET")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                .foregroundColor(Color("text_3Color"))
                                .textCase(.uppercase)
                            
                            Text("$\(project.budget)")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                .foregroundColor(Color("text_1Color"))
                        }
                    }
                    .padding(screenWidth * 0.03)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.035)
                            .fill(Color.gray.opacity(0.2))
                    )
                }
            }
            .padding(screenWidth * 0.04)
            .background(
                RoundedRectangle(cornerRadius: screenHeight * 0.04)
                    .fill(Color.white)
            )
            .padding(.horizontal, screenWidth * 0.05)
            
            Text("Checklist")
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.024))
                .foregroundColor(Color("text_1Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, screenWidth * 0.05)
            
            if project.tasks.isEmpty {
                Text("No tasks")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                    .foregroundColor(Color("text_1Color").opacity(0.6))
            } else {
                VStack(spacing: screenHeight * 0.015) {
                    ForEach(project.tasks) { task in
                        HStack(alignment: .center, spacing: screenWidth * 0.03) {
                            Image(task.isCompleted ? "doneCircle" : "notDoneCircle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                            
                            Text(task.title)
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                .foregroundColor(Color("text_1Color"))
                                .strikethrough(task.isCompleted, color: Color("text_1Color"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(screenWidth * 0.04)
                        .frame(width: screenWidth * 0.9)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                        .stroke(task.isCompleted ? Color("part_1Color") : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
            }
        }
    }
}

struct ReadOnlyBudgetView: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            HStack(spacing: screenWidth * 0.04) {
                ZStack {
                    Image("totalBudgetFrame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.43)
                    
                    VStack(spacing: screenHeight * 0.005) {
                        Text("$\(String(format: "%.2f", project.totalBudget))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.03))
                            .foregroundColor(Color("text_1Color"))
                            .padding(.top, screenHeight * 0.04)
                    }
                }
                
                ZStack {
                    Image("remainingFrame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.43)
                    
                    VStack(spacing: screenHeight * 0.005) {
                        Text("$\(String(format: "%.2f", project.remainingBudget))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.03))
                            .foregroundColor(Color("text_1Color"))
                            .padding(.top, screenHeight * 0.04)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            Text("Expense Log")
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.024))
                .foregroundColor(Color("text_1Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, screenWidth * 0.05)
            
            if project.expenses.isEmpty {
                Text("No expenses")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                    .foregroundColor(Color("text_1Color").opacity(0.6))
            } else {
                VStack(spacing: screenHeight * 0.015) {
                    ForEach(project.expenses) { expense in
                        HStack(spacing: screenWidth * 0.03) {
                            Image(expense.type.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenHeight * 0.04, height: screenHeight * 0.04)
                            
                            VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                                Text(expense.store)
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                    .foregroundColor(Color("text_1Color"))
                                
                                Text(expense.item)
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                                    .foregroundColor(Color("text_1Color").opacity(0.7))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: screenHeight * 0.005) {
                                Text("$\(String(format: "%.2f", expense.amount))")
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                    .foregroundColor(Color("text_1Color"))
                                
                                Text(String(format: "%.1f%%", (expense.amount / project.totalSpent) * 100))
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                                    .foregroundColor(Color("text_1Color").opacity(0.7))
                            }
                        }
                        .padding(screenWidth * 0.04)
                        .frame(width: screenWidth * 0.9)
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color.white)
                        )
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.01) {
            Text(title)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                .foregroundColor(Color("text_1Color"))
            
            Text(value)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                .foregroundColor(Color("text_1Color"))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                        .fill(Color.white)
                )
        }
    }
}

#Preview {
    Statistic()
}
