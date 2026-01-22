//
//  MainTab.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

enum ProjectFilter: String, CaseIterable, Codable {
    case active = "Active Projects"
    case planning = "Planning"
    case completed = "Completed"
}

struct MainTab: View {
    @State private var selectedFilter: ProjectFilter = .active
    @State private var showAddProject = false
    @ObservedObject private var projectManager = ProjectManager.shared
    
    private var filteredProjects: [Project] {
        projectManager.projects.filter { $0.status == selectedFilter }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Text("Main")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.035))
                    .foregroundColor(Color("text_1Color"))
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showAddProject = true
                    }) {
                        Image("plusIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.04, height: screenHeight * 0.04)
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            .padding(.top, screenHeight * 0.025)
            .padding(.bottom, screenHeight * 0.025)
            
            // Filter buttons
            HStack(spacing: screenWidth * 0.025) {
                ForEach(ProjectFilter.allCases, id: \.self) { filter in
                    FilterButton(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            .padding(.bottom, screenHeight * 0.025)
            
            // Content area
            if filteredProjects.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    VStack(spacing: screenHeight * 0.02) {
                        ForEach(filteredProjects) { project in
                            ProjectCard(project: project)
                        }
                    }
                    .padding(.vertical, screenHeight * 0.02)
                }
            }
        }
        .fullScreenCover(isPresented: $showAddProject) {
            AddProjectView()
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                .foregroundColor(isSelected ? Color.white : Color("text_1Color"))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, screenWidth * 0.04)
                .padding(.vertical, screenHeight * 0.012)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.025)
                        .fill(isSelected ? Color("part_1Color") : Color.white)
                )
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("notYetIcon")
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.06, height: screenHeight * 0.06)
            
            Text("No project yet")
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.025))
                .foregroundColor(Color("text_1Color"))
                .padding(.top, screenHeight * 0.02)
            
            Text("Click on the plus\nsign to add")
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                .foregroundColor(Color("text_1Color").opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.top, screenHeight * 0.01)
            
            Spacer()
        }
    }
}

#Preview {
    MainTab()
}
