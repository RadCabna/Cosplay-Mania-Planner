//
//  AddTaskView.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import SwiftUI

struct AddTaskView: View {
    let onAdd: (ChecklistTask) -> Void
    let onDismiss: () -> Void
    
    @State private var taskTitle = ""
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background dimming
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        onDismiss()
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Bottom sheet
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        Text("Add Task")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.028))
                            .foregroundColor(Color("text_1Color"))
                        
                        HStack {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    onDismiss()
                                }
                            }) {
                                Image("backButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight * 0.03)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.top, screenHeight * 0.025)
                    .padding(.bottom, screenHeight * 0.02)
                    
                    VStack(spacing: screenHeight * 0.02) {
                        // Task description
                        VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                            Text("Describe the task")
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                                .foregroundColor(Color("text_1Color"))
                            
                            TextField("Buy fabric, make pattern, sew costume", text: $taskTitle)
                                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                .foregroundColor(Color("text_1Color"))
                                .colorScheme(.light)
                                .accentColor(Color("part_1Color"))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                        .fill(Color.white)
                                )
                        }
                        .padding(.horizontal, screenWidth * 0.05)
                    }
                    .padding(.vertical, screenHeight * 0.02)
                    
                    // Add button
                    Button(action: {
                        guard !taskTitle.isEmpty else { return }
                        
                        let task = ChecklistTask(title: taskTitle)
                        onAdd(task)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            onDismiss()
                        }
                    }) {
                        Image("addButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.07)
                            .opacity(taskTitle.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.02)
                }
                .frame(height: screenHeight * 0.35)
                .background(Color("bgColor"))
                .cornerRadius(screenHeight * 0.03, corners: [.topLeft, .topRight])
                .offset(y: -keyboardHeight)
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        keyboardHeight = keyboardFrame.height - (deviceHasSafeArea ? 0 : 20)
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    keyboardHeight = 0
                }
            }
        }
    }
}

#Preview {
    AddTaskView(
        onAdd: { _ in },
        onDismiss: { }
    )
}
