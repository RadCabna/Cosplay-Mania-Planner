//
//  Main.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case main = 0
    case notification = 1
    case statistic = 2
    
    var title: String {
        switch self {
        case .main: return "Main"
        case .notification: return "Notification"
        case .statistic: return "Statistic"
        }
    }
    
    var iconOn: String {
        switch self {
        case .main: return "mainOn"
        case .notification: return "notificationOn"
        case .statistic: return "statisticOn"
        }
    }
    
    var iconOff: String {
        switch self {
        case .main: return "mainOff"
        case .notification: return "notificationOff"
        case .statistic: return "statisticOff"
        }
    }
}

struct Main: View {
    @State private var selectedTab: TabItem = .main
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content area
                ZStack {
                    switch selectedTab {
                    case .main:
                        MainTab()
                            .transition(.opacity)
                    case .notification:
                        Notification()
                            .transition(.opacity)
                    case .statistic:
                        Statistic()
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer(minLength: 0)
                
                // Bottom Bar
                BottomBar(selectedTab: $selectedTab, animation: animation)
            }
            .padding(.bottom, 10)
        }
    }
}

struct BottomBar: View {
    @Binding var selectedTab: TabItem
    var animation: Namespace.ID
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    selectedTab: $selectedTab,
                    animation: animation
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white)
        )
        .frame(width: screenWidth - 40)
        .frame(maxWidth: .infinity)
    }
    
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
}

struct TabButton: View {
    let tab: TabItem
    @Binding var selectedTab: TabItem
    var animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 8) {
            Image(selectedTab == tab ? tab.iconOn : tab.iconOff)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            
            Text(tab.title)
                .font(.custom("SFProDisplay-Semibold", size: 12))
                .foregroundColor(selectedTab == tab ? Color("part_1Color") : Color("text_1Color"))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: screenHeight*0.05)
                        .fill(Color("part_1Color").opacity(0.2))
                        .matchedGeometryEffect(id: "TAB_BACKGROUND", in: animation)
                        .frame(width: screenHeight*0.13)
                }
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }
    }
}

#Preview {
    Main()
}
