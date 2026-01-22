//
//  AddProjectView.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI
import PhotosUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var projectManager = ProjectManager.shared
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var projectName = ""
    @State private var source = ""
    @State private var eventName = ""
    @State private var budget = ""
    @State private var eventDate = Date()
    
    @State private var showProjectNameError = false
    @State private var showSourceError = false
    @State private var showEventNameError = false
    @State private var showBudgetError = false
    
    private var allFieldsFilled: Bool {
        !projectName.isEmpty && !source.isEmpty && !eventName.isEmpty && !budget.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Add Project")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.035))
                        .foregroundColor(Color("text_1Color"))
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image("backButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenHeight * 0.04, height: screenHeight * 0.04)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.top, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.025)
                
                // ScrollView with form
                ScrollView {
                    VStack(spacing: screenHeight * 0.025) {
                        // Photo button
                        Button(action: {
                            showImagePicker = true
                        }) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenHeight * 0.15, height: screenHeight * 0.15)
                                    .clipShape(Circle())
                            } else {
                                Image("addPhotoButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: screenHeight * 0.15, height: screenHeight * 0.15)
                            }
                        }
                        .padding(.top, screenHeight * 0.02)
                        
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
                                TextField("200$", text: $budget)
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                    .foregroundColor(Color("text_1Color"))
                                    .colorScheme(.light)
                                    .accentColor(Color("part_1Color"))
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                            .fill(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                                    .stroke(showBudgetError ? Color.red : Color.clear, lineWidth: 2)
                                            )
                                    )
                                    .onChange(of: budget) { _ in
                                        showBudgetError = false
                                    }
                                
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
                        .padding(.bottom, screenHeight * 0.02)
                    }
                }
                
                // Add button
                Button(action: {
                    if allFieldsFilled {
                        // Save project data
                        let project = Project(
                            projectName: projectName,
                            source: source,
                            eventName: eventName,
                            budget: budget,
                            eventDate: eventDate,
                            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
                            status: .planning
                        )
                        projectManager.addProject(project)
                        dismiss()
                    } else {
                        // Show errors for empty fields
                        showProjectNameError = projectName.isEmpty
                        showSourceError = source.isEmpty
                        showEventNameError = eventName.isEmpty
                        showBudgetError = budget.isEmpty
                    }
                }) {
                    Image("addButton")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.07)
                        .opacity(allFieldsFilled ? 1.0 : 0.5)
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.vertical, screenHeight * 0.02)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    AddProjectView()
}
