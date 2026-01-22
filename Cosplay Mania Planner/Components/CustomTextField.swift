//
//  CustomTextField.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 21.01.2026.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding(.leading, screenWidth * 0.04)
            }
            
            TextField("", text: $text)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.02))
                .foregroundColor(Color("text_1Color"))
                .keyboardType(keyboardType)
                .accentColor(Color("part_1Color"))
                .padding()
        }
        .colorScheme(.light)
    }
}
