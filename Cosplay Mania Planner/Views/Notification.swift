//
//  Notification.swift
//  Cosplay Mania Planner
//
//  Created by Алкександр Степанов on 20.01.2026.
//

import SwiftUI

struct Notification: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var openedNotificationId: UUID?
    
    var body: some View {
        ZStack {
            Color("bgColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Notifications")
                    .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.028))
                    .foregroundColor(Color("text_1Color"))
                    .padding(.top, screenHeight * 0.025)
                    .padding(.bottom, screenHeight * 0.02)
                
                // Notifications list
                if notificationManager.notifications.isEmpty {
                    VStack(spacing: screenHeight * 0.02) {
                        Image("notYetIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenHeight * 0.06, height: screenHeight * 0.06)
                        
                        Text("No notifications yet")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.024))
                            .foregroundColor(Color("text_1Color"))
                        
                        Text("We'll notify you about\nupcoming events")
                            .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_1Color").opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: screenHeight * 0.015) {
                            ForEach(notificationManager.notifications) { notification in
                                NotificationRow(
                                    notification: notification,
                                    openedNotificationId: $openedNotificationId,
                                    onDelete: {
                                        notificationManager.deleteNotification(notification)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, screenWidth * 0.05)
                        .padding(.vertical, screenHeight * 0.02)
                    }
                }
            }
        }
        .onAppear {
            notificationManager.checkAndAddDueNotifications()
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    @Binding var openedNotificationId: UUID?
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Swipe action background
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        offset = -screenWidth
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDelete()
                        }
                    }
                }) {
                    Image("deleteTask")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                }
                .padding(.trailing, screenWidth * 0.05)
            }
            .frame(width: screenWidth * 0.9)
            
            // Main content
            Text(notification.message)
                .font(.custom("SFProDisplay-Semibold", size: screenHeight * 0.018))
                .foregroundColor(Color("text_1Color"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(screenWidth * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.02)
                        .fill(Color.white)
                )
                .frame(width: screenWidth * 0.9)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                offset = max(gesture.translation.width, -screenWidth * 0.25)
                            } else if offset < 0 {
                                offset = min(0, offset + gesture.translation.width)
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring()) {
                                if gesture.translation.width < -50 {
                                    offset = -screenWidth * 0.25
                                    openedNotificationId = notification.id
                                } else {
                                    offset = 0
                                    if openedNotificationId == notification.id {
                                        openedNotificationId = nil
                                    }
                                }
                            }
                        }
                )
        }
        .onChange(of: openedNotificationId) { newId in
            if newId != notification.id && offset != 0 {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
    }
}

#Preview {
    Notification()
}
