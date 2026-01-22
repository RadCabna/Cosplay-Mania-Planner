//
//  Loading.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

struct Loading: View {
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Loading...")
                    .font(.custom("SFProDisplay-Semibold", size: 24))
                    .foregroundColor(Color("text_1Color"))
                    .padding(.bottom, 50)
            }
        }
        .frame(height: screenHeight)
    }
}

#Preview {
    Loading()
}
