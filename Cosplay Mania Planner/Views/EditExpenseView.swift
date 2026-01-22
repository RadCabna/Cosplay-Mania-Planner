//
//  EditExpenseView.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) var dismiss
    let expense: Expense
    let onUpdate: (Expense) -> Void
    
    @State private var store: String
    @State private var item: String
    @State private var amount: String
    @State private var selectedType: ExpenseType
    
    init(expense: Expense, onUpdate: @escaping (Expense) -> Void) {
        self.expense = expense
        self.onUpdate = onUpdate
        _store = State(initialValue: expense.store)
        _item = State(initialValue: expense.item)
        _amount = State(initialValue: String(expense.amount))
        _selectedType = State(initialValue: expense.type)
    }
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Edit expense")
                        .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.028))
                        .foregroundColor(Color("text_1Color"))
                    
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
                
                // Save button
                Button(action: {
                    guard !store.isEmpty, !item.isEmpty, let amountValue = Double(amount) else {
                        return
                    }
                    
                    var updatedExpense = expense
                    updatedExpense.store = store
                    updatedExpense.item = item
                    updatedExpense.amount = amountValue
                    updatedExpense.type = selectedType
                    
                    onUpdate(updatedExpense)
                    dismiss()
                }) {
                    Image("saveButton")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.07)
                }
                .padding(.horizontal, screenWidth * 0.05)
                .padding(.vertical, screenHeight * 0.02)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    EditExpenseView(
        expense: Expense(
            store: "Test Store",
            item: "Test Item",
            amount: 100,
            type: .fabricOutfit
        ),
        onUpdate: { _ in }
    )
}
