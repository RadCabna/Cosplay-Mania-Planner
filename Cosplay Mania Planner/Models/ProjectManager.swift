//
//  ProjectManager.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import Foundation

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var projects: [Project] = []
    @Published var archivedProjects: [Project] = []
    
    private init() {
        loadProjects()
        loadArchivedProjects()
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
        
        // Schedule notifications for the new project
        NotificationManager.shared.scheduleNotifications(for: project)
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        
        // Archive the deleted project
        archivedProjects.insert(project, at: 0)
        
        saveProjects()
        saveArchivedProjects()
        
        // Cancel notifications for deleted project
        NotificationManager.shared.cancelNotifications(for: project.id)
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
            
            // Reschedule notifications if event date changed
            NotificationManager.shared.cancelNotifications(for: project.id)
            NotificationManager.shared.scheduleNotifications(for: project)
        }
    }
    
    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: "savedProjects")
        }
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: "savedProjects"),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }
    
    private func saveArchivedProjects() {
        if let encoded = try? JSONEncoder().encode(archivedProjects) {
            UserDefaults.standard.set(encoded, forKey: "archivedProjects")
        }
    }
    
    private func loadArchivedProjects() {
        if let data = UserDefaults.standard.data(forKey: "archivedProjects"),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            archivedProjects = decoded
        }
    }
}
