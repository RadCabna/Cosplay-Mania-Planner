//
//  AddExpenseView.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import SwiftUI

struct AddExpenseView: View {
    let onAdd: (Expense) -> Void
    let onDismiss: () -> Void
    
    @State private var store = ""
    @State private var item = ""
    @State private var amount = ""
    @State private var selectedType: ExpenseType = .fabricOutfit
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
                        Text("Add expense")
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
                    
                    ScrollView {
                        VStack(spacing: screenHeight * 0.02) {
                            // Store
                            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                                Text("Store")
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                                    .foregroundColor(Color("text_1Color"))
                                
                                TextField("Fabric shop, online store, market", text: $store)
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
                            
                            // Item
                            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                                Text("Item")
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                                    .foregroundColor(Color("text_1Color"))
                                
                                TextField("Wig, fabric, paint", text: $item)
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
                            
                            // Amount
                            VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                                Text("Amount")
                                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.022))
                                    .foregroundColor(Color("text_1Color"))
                                
                                HStack(spacing: 0) {
                                    Text("$")
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                        .foregroundColor(Color("text_1Color"))
                                        .padding(.leading, screenWidth * 0.04)
                                    
                                    TextField("Total cost", text: $amount)
                                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                                        .foregroundColor(Color("text_1Color"))
                                        .colorScheme(.light)
                                        .accentColor(Color("part_1Color"))
                                        .keyboardType(.decimalPad)
                                        .padding(.vertical, screenHeight * 0.015)
                                        .padding(.trailing, screenWidth * 0.04)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                                        .fill(Color.white)
                                )
                            }
                            .padding(.horizontal, screenWidth * 0.05)
                            
                            // Expense types horizontal scroll
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: screenWidth * 0.03) {
                                    ForEach(ExpenseType.allCases, id: \.self) { type in
                                        ExpenseTypeButton(
                                            type: type,
                                            isSelected: selectedType == type
                                        ) {
                                            selectedType = type
                                        }
                                    }
                                }
                                .padding(.horizontal, screenWidth * 0.05)
                            }
                            .padding(.vertical, screenHeight * 0.01)
                        }
                    }
                    
                    // Add button
                    Button(action: {
                        guard !store.isEmpty, !item.isEmpty, let amountValue = Double(amount) else {
                            return
                        }
                        
                        let expense = Expense(
                            store: store,
                            item: item,
                            amount: amountValue,
                            type: selectedType,
                            date: Date()
                        )
                        onAdd(expense)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            onDismiss()
                        }
                    }) {
                        Image("addExpenseButton")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.07)
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                    .padding(.vertical, screenHeight * 0.02)
                }
                .frame(height: screenHeight * 0.5)
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

struct ExpenseTypeButton: View {
    let type: ExpenseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                .foregroundColor(isSelected ? .white : Color("text_1Color"))
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.vertical, screenHeight * 0.012)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.015)
                        .fill(isSelected ? Color("part_1Color") : .white)
                )
        }
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    AddExpenseView(
        onAdd: { _ in },
        onDismiss: { }
    )
}
