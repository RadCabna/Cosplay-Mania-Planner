//
//  ProjectDetailView.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import SwiftUI

enum ProjectDetailTab: String, CaseIterable {
    case details = "Details"
    case stages = "Stages"
    case budget = "Budget"
}

struct ProjectDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var projectManager = ProjectManager.shared
    @Namespace private var animation
    
    let projectId: UUID
    @State private var localProject: Project
    @State private var selectedTab: ProjectDetailTab = .details
    @State private var showDeleteAlert = false
    @State private var showAddExpense = false
    @State private var showAddTask = false
    @State private var showImagePicker = false
    
    init(projectId: UUID) {
        self.projectId = projectId
        let foundProject = ProjectManager.shared.projects.first(where: { $0.id == projectId }) ?? Project(
            projectName: "",
            source: "",
            eventName: "",
            budget: "0",
            eventDate: Date()
        )
        _localProject = State(initialValue: foundProject)
    }
    
    private func syncWithManager() {
        projectManager.updateProject(localProject)
    }
    
    private func updateStatusOnDismiss() {
        // Update status based on tasks completion when closing the screen
        if !localProject.tasks.isEmpty {
            let completedCount = localProject.tasks.filter { $0.isCompleted }.count
            let totalCount = localProject.tasks.count
            
            if completedCount == totalCount {
                // All tasks completed → move to Completed
                localProject.status = .completed
            } else if completedCount > 0 {
                // Some tasks completed (not all) → move to Active
                // This handles both Planning → Active and Completed → Active
                localProject.status = .active
            } else if completedCount == 0 && localProject.status == .completed {
                // Was completed but now no tasks are completed → move to Active
                localProject.status = .active
            }
            // If completedCount == 0 and status is Planning, keep it in Planning
        }
        
        syncWithManager()
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text(localProject.projectName)
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.028))
                        .foregroundColor(Color("text_1Color"))
                        .lineLimit(1)
                        .padding(.horizontal, screenWidth * 0.2)
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image("backButton")
                                .resizable()
                                .scaledToFit()
                                .frame( height: screenHeight * 0.03)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            Image("deleteIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight * 0.03)
                        }
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.025)
                
                ScrollView {
                    VStack(spacing: screenHeight * 0.025) {
                        // Project Image with overlay
                        ZStack(alignment: .bottomLeading) {
                            Group {
                                if let image = localProject.image {
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
                            }
                            .onTapGesture {
                                showImagePicker = true
                            }
                            
                            // Status and event info overlay
                            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                                // Status icon
                                Image(localProject.status == .completed ? "doneIcon" : "inProgressIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight * 0.03)
                                
                                // Event info
                                HStack(spacing: screenWidth * 0.02) {
                                    Image("calendarIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                                    
                                    Text(localProject.eventName)
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                        .foregroundColor(.white)
                                    
                                    Text("-")
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                        .foregroundColor(.white)
                                    
                                    Text(formattedDate(localProject.eventDate))
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
                        
                        // Tab selector
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
                        
                        // Tab content
                        switch selectedTab {
                        case .details:
                            DetailsTabView(project: $localProject, onUpdate: syncWithManager, onTabChange: {
                                // Save changes when switching tabs
                                syncWithManager()
                            })
                        case .stages:
                            StagesTabView(project: $localProject, showAddTask: $showAddTask, onUpdate: syncWithManager)
                        case .budget:
                            BudgetTabView(project: $localProject, showAddExpense: $showAddExpense, onUpdate: syncWithManager)
                        }
                    }
                    .padding(.vertical, screenHeight * 0.02)
                }
            }
        }
        .overlay(
            Group {
                if showAddExpense {
                    AddExpenseView(
                        onAdd: { expense in
                            localProject.expenses.append(expense)
                            syncWithManager()
                            showAddExpense = false
                        },
                        onDismiss: {
                            showAddExpense = false
                        }
                    )
                }
                
                if showAddTask {
                    AddTaskView(
                        onAdd: { task in
                            localProject.tasks.append(task)
                            syncWithManager()
                            showAddTask = false
                        },
                        onDismiss: {
                            showAddTask = false
                        }
                    )
                }
            }
        )
        .navigationBarHidden(true)
        .onDisappear {
            updateStatusOnDismiss()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: Binding(
                get: { localProject.image },
                set: { newImage in
                    localProject.imageData = newImage?.jpegData(compressionQuality: 0.8)
                    syncWithManager()
                }
            ))
        }
        .alert("Delete Project", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                projectManager.deleteProject(localProject)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this project?")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct DetailTabButton: View {
    let title: String
    let isSelected: Bool
    var animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: screenHeight * 0.025)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .matchedGeometryEffect(id: "TAB_BACKGROUND", in: animation)
                }
                
                Text(title)
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                    .foregroundColor(Color("text_1Color"))
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.012)
            }
        }
    }
}

// Details tab with editing functionality
struct DetailsTabView: View {
    @Binding var project: Project
    let onUpdate: () -> Void
    let onTabChange: () -> Void
    
    @State private var projectName: String
    @State private var source: String
    @State private var eventName: String
    @State private var budget: String
    @State private var eventDate: Date
    
    @State private var showProjectNameError = false
    @State private var showSourceError = false
    @State private var showEventNameError = false
    @State private var showBudgetError = false
    
    init(project: Binding<Project>, onUpdate: @escaping () -> Void, onTabChange: @escaping () -> Void) {
        self._project = project
        self.onUpdate = onUpdate
        self.onTabChange = onTabChange
        _projectName = State(initialValue: project.wrappedValue.projectName)
        _source = State(initialValue: project.wrappedValue.source)
        _eventName = State(initialValue: project.wrappedValue.eventName)
        _budget = State(initialValue: project.wrappedValue.budget)
        _eventDate = State(initialValue: project.wrappedValue.eventDate)
    }
    
    private func saveChanges() {
        project.projectName = projectName
        project.source = source
        project.eventName = eventName
        project.budget = budget
        project.eventDate = eventDate
    }
    
    private var allFieldsFilled: Bool {
        !projectName.isEmpty && !source.isEmpty && !eventName.isEmpty && !budget.isEmpty
    }
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            // Project name
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                Text("Project name")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                    .foregroundColor(Color("text_1Color"))
                
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    TextField("Who are you becoming?", text: $projectName)
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_1Color"))
                        .colorScheme(.light)
                        .accentColor(Color("part_1Color"))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                        .stroke(showProjectNameError ? Color.red : Color.clear, lineWidth: 2)
                                )
                        )
                        .onChange(of: projectName) { _ in
                            showProjectNameError = false
                        }
                    
                    if showProjectNameError {
                        Text("You need to fill in this field")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Source
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                Text("Source")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                    .foregroundColor(Color("text_1Color"))
                
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    TextField("Original Character", text: $source)
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_1Color"))
                        .colorScheme(.light)
                        .accentColor(Color("part_1Color"))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                        .stroke(showSourceError ? Color.red : Color.clear, lineWidth: 2)
                                )
                        )
                        .onChange(of: source) { _ in
                            showSourceError = false
                        }
                    
                    if showSourceError {
                        Text("You need to fill in this field")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Event name
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                Text("Event name")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                    .foregroundColor(Color("text_1Color"))
                
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    TextField("Anime Fest 2025", text: $eventName)
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_1Color"))
                        .colorScheme(.light)
                        .accentColor(Color("part_1Color"))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                        .stroke(showEventNameError ? Color.red : Color.clear, lineWidth: 2)
                                )
                        )
                        .onChange(of: eventName) { _ in
                            showEventNameError = false
                        }
                    
                    if showEventNameError {
                        Text("You need to fill in this field")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Budget
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                Text("Budget")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                    .foregroundColor(Color("text_1Color"))
                
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    HStack(spacing: 0) {
                        Text("$")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                            .foregroundColor(Color("text_1Color"))
                            .padding(.leading, screenWidth * 0.04)
                        
                        TextField("200", text: $budget)
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                            .foregroundColor(Color("text_1Color"))
                            .colorScheme(.light)
                            .accentColor(Color("part_1Color"))
                            .keyboardType(.numberPad)
                            .padding(.vertical, screenHeight * 0.015)
                            .padding(.trailing, screenWidth * 0.04)
                            .onChange(of: budget) { _ in
                                showBudgetError = false
                            }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.02)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                    .stroke(showBudgetError ? Color.red : Color.clear, lineWidth: 2)
                            )
                    )
                    
                    if showBudgetError {
                        Text("You need to fill in this field")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.016))
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Date picker
            VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                Text("When is it happening")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                    .foregroundColor(Color("text_1Color"))
                
                DatePicker("", selection: $eventDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.light)
                    .accentColor(Color("part_1Color"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.02)
                            .fill(Color.white)
                    )
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Save button
            Button(action: {
                if allFieldsFilled {
                    saveChanges()
                    onUpdate()
                } else {
                    // Show errors
                    showProjectNameError = projectName.isEmpty
                    showSourceError = source.isEmpty
                    showEventNameError = eventName.isEmpty
                    showBudgetError = budget.isEmpty
                }
            }) {
                Image("saveButton")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.07)
                    .opacity(allFieldsFilled ? 1.0 : 0.5)
            }
            .padding(.horizontal, screenWidth * 0.05)
            .padding(.vertical, screenHeight * 0.02)
        }
        .onDisappear {
            // Save changes when leaving Details tab (switching to Stages/Budget)
            // But not when going back (handled by parent)
            saveChanges()
            onTabChange()
        }
    }
}

struct StagesTabView: View {
    @Binding var project: Project
    @Binding var showAddTask: Bool
    let onUpdate: () -> Void
    @State private var openedTaskId: UUID?
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            // Competition Rate Card
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
                
                // Progress bar
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
                
                // Time and Budget cards
                HStack(spacing: screenWidth * 0.03) {
                    // Time left
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
                    
                    // Budget
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
            .padding(.top, screenHeight * 0.02)
            
            // Checklist Header
            HStack {
                Text("Checklist")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.024))
                    .foregroundColor(Color("text_1Color"))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showAddTask = true
                    }
                }) {
                    Image("plusIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.035)
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Tasks List
            if project.tasks.isEmpty {
                VStack(spacing: screenHeight * 0.02) {
                    Text("No tasks yet")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_1Color").opacity(0.6))
                        .padding(.top, screenHeight * 0.04)
                }
            } else {
                VStack(spacing: screenHeight * 0.015) {
                    ForEach(project.tasks) { task in
                        TaskRow(
                            task: task,
                            openedTaskId: $openedTaskId,
                            onToggle: {
                                if let index = project.tasks.firstIndex(where: { $0.id == task.id }) {
                                    project.tasks[index].isCompleted.toggle()
                                    onUpdate()
                                }
                            },
                            onDelete: {
                                project.tasks.removeAll { $0.id == task.id }
                                onUpdate()
                            }
                        )
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
            }
            
            Spacer()
        }
    }
}

struct TaskRow: View {
    let task: ChecklistTask
    @Binding var openedTaskId: UUID?
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Swipe action background
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        offset = -screenWidth
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                        }
                    }
                }) {
                    Image("deleteTask")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                }
            }
            .frame(width: screenWidth * 0.9)
            
            // Main content
            HStack(alignment: .center, spacing: screenWidth * 0.03) {
                Button(action: onToggle) {
                    Image(task.isCompleted ? "doneCircle" : "notDoneCircle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                }
                
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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = max(gesture.translation.width, -screenWidth * 0.18)
                        } else if offset < 0 {
                            offset = min(0, offset + gesture.translation.width)
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -50 {
                                offset = -screenWidth * 0.18
                                openedTaskId = task.id
                            } else {
                                offset = 0
                                if openedTaskId == task.id {
                                    openedTaskId = nil
                                }
                            }
                        }
                    }
            )
        }
        .onChange(of: openedTaskId) { newId in
            if newId != task.id && offset != 0 {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
    }
}

struct BudgetTabView: View {
    @Binding var project: Project
    @Binding var showAddExpense: Bool
    let onUpdate: () -> Void
    @State private var openedExpenseId: UUID?
    
    var body: some View {
        VStack(spacing: screenHeight * 0.025) {
            // Budget overview
            HStack(spacing: screenWidth * 0.04) {
                // Total Budget Frame
                ZStack {
                    Image("totalBudgetFrame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.43)
                    
                    VStack(spacing: screenHeight * 0.005) {
                        Text("$\(String(format: "%.2f", project.totalBudget))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.03))
                            .foregroundColor(Color("text_1Color"))
                            .padding(.top, screenHeight*0.04)
                    }
                }
                
                // Remaining Budget Frame
                ZStack {
                    Image("remainingFrame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.43)
                    
                    VStack(spacing: screenHeight * 0.005) {
                        
                        Text("$\(String(format: "%.2f", project.remainingBudget))")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.03))
                            .foregroundColor(Color("text_1Color"))
                            .padding(.top, screenHeight*0.04)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            .padding(.top, screenHeight * 0.02)
            
            // Expense Log Header
            HStack {
                Text("Expense Log")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.024))
                    .foregroundColor(Color("text_1Color"))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showAddExpense = true
                    }
                }) {
                    Image("plusIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.035)
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Expenses List
            if project.expenses.isEmpty {
                VStack(spacing: screenHeight * 0.02) {
                    Text("No expenses yet")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_1Color").opacity(0.6))
                        .padding(.top, screenHeight * 0.04)
                }
            } else {
                VStack(spacing: screenHeight * 0.015) {
                    ForEach(project.expenses) { expense in
                        ExpenseRow(
                            expense: expense,
                            totalSpent: project.totalSpent,
                            project: project,
                            openedExpenseId: $openedExpenseId,
                            onEdit: { updatedExpense in
                                if let index = project.expenses.firstIndex(where: { $0.id == expense.id }) {
                                    project.expenses[index] = updatedExpense
                                    onUpdate()
                                }
                            },
                            onDelete: {
                                project.expenses.removeAll { $0.id == expense.id }
                                onUpdate()
                            }
                        )
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
            }
            
            Spacer()
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let totalSpent: Double
    let project: Project
    @Binding var openedExpenseId: UUID?
    let onEdit: (Expense) -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var showEditExpense = false
    
    private var percentage: String {
        guard totalSpent > 0 else { return "0%" }
        let percent = (expense.amount / totalSpent) * 100
        return String(format: "%.1f%%", percent)
    }
    
    var body: some View {
        ZStack {
            // Swipe actions background
            HStack(spacing: screenWidth * 0.02) {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        offset = 0
                        showEditExpense = true
                    }
                }) {
                    Image("editLogIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                }
                
                Button(action: {
                    withAnimation {
                        offset = -screenWidth
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                        }
                    }
                }) {
                    Image("deleteLogIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                }
            }
            .frame(width: screenWidth * 0.9)
            
            // Main content
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
                    
                    Text(percentage)
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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            offset = max(gesture.translation.width, -screenWidth * 0.42)
                        } else if offset < 0 {
                            offset = min(0, offset + gesture.translation.width)
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if gesture.translation.width < -50 {
                                offset = -screenWidth * 0.42
                                openedExpenseId = expense.id
                            } else {
                                offset = 0
                                if openedExpenseId == expense.id {
                                    openedExpenseId = nil
                                }
                            }
                        }
                    }
            )
        }
        .onChange(of: openedExpenseId) { newId in
            if newId != expense.id && offset != 0 {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
        .fullScreenCover(isPresented: $showEditExpense) {
            EditExpenseView(
                expense: expense,
                onUpdate: { updatedExpense in
                    onEdit(updatedExpense)
                }
            )
        }
    }
}

#Preview {
    ProjectDetailView(projectId: UUID())
}
