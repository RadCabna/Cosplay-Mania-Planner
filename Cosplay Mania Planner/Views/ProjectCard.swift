//
//  ProjectCard.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

struct ProjectCard: View {
    let project: Project
    @State private var showDetail = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Project Frame
            Image("projectFrame")
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth * 0.9, height: screenHeight * 0.35)
            
            VStack(spacing: 0) {
                // Project Image
                ZStack(alignment: .topTrailing) {
                    if let image = project.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.35 * 2/3)
                            .clipShape(
                                RoundedRectangle(cornerRadius: screenHeight * 0.035)
                            )
                            .clipped()
                    } else {
                        // Placeholder if no image
                        RoundedRectangle(cornerRadius: screenHeight * 0.035)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.35 * 2/3)
                    }
                    
                    // Budget badge (top right)
                    HStack(spacing: screenWidth * 0.015) {
                        Image("budgetIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.025, height: screenHeight * 0.025)
                        
                        Text("$\(project.budget)")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color"))
                    }
                    .padding(.horizontal, screenWidth * 0.03)
                    .padding(.vertical, screenHeight * 0.01)
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.015)
                            .fill(Color.white)
                    )
                    .padding(.top, screenHeight * 0.015)
                    .padding(.trailing, screenHeight * 0.015)
                    
                    // Text overlay (bottom left)
                    VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                        Spacer()
                        
                        Text(project.source)
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                            .foregroundColor(.white)
                        
                        Text(project.eventName)
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, screenHeight * 0.02)
                    .padding(.bottom, screenHeight * 0.015)
                }
                .frame(width: screenWidth * 0.9, height: screenHeight * 0.35 * 2/3)
                
                // Progress section
                HStack(spacing: screenWidth * 0.04) {
                    // Left side - Progress bar
                    VStack(alignment: .leading, spacing: screenHeight * 0.008) {
                        HStack {
                            Text("OVERALL PROGRESS")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                                .foregroundColor(Color("text_1Color"))
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            Text("\(Int(project.completionPercentage))%")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                .foregroundColor(Color("text_1Color"))
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: screenHeight * 0.016)
                                    .fill(Color("part_1Color").opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: screenHeight * 0.016)
                                    .fill(Color("part_1Color"))
                                    .frame(width: geometry.size.width * CGFloat(project.completionPercentage / 100))
                            }
                        }
                        .frame(height: screenHeight * 0.025)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right side - Circular progress
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(
                                Color("part_1Color").opacity(0.1),
                                lineWidth: screenHeight * 0.006
                            )
                            .frame(width: screenHeight * 0.055, height: screenHeight * 0.055)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: CGFloat(project.completionPercentage / 100))
                            .stroke(
                                Color("part_1Color"),
                                style: StrokeStyle(
                                    lineWidth: screenHeight * 0.006,
                                    lineCap: .round
                                )
                            )
                            .frame(width: screenHeight * 0.055, height: screenHeight * 0.055)
                            .rotationEffect(.degrees(-90))
                        
                        // Center icon
                        Image("doneCircle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.03, height: screenHeight * 0.03)
                    }
                }
                .padding(.horizontal, screenHeight * 0.02)
                .padding(.top, screenHeight * 0.025)
                
                Spacer()
            }
        }
        .frame(width: screenWidth * 0.9, height: screenHeight * 0.35)
        .onTapGesture {
            showDetail = true
        }
        .fullScreenCover(isPresented: $showDetail) {
            ProjectDetailView(projectId: project.id)
                .id(project.id)
        }
    }
}

#Preview {
    ProjectCard(project: Project(
        projectName: "Sakura Haruno",
        source: "Naruto",
        eventName: "Anime Fest 2025",
        budget: "350",
        eventDate: Date()
    ))
}
