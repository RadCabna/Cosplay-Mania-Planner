import SwiftUI
import UIKit

class OrientationManager: ObservableObject {
    @Published var isHorizontalLock = true
    
    static var shared: OrientationManager = .init()
    
    func lockToPortrait() {
        DispatchQueue.main.async {
            self.isHorizontalLock = true
            self.forceUpdateOrientation()
        }
    }
    
    func unlockAllOrientations() {
        DispatchQueue.main.async {
            self.isHorizontalLock = false
            self.forceUpdateOrientation()
        }
    }
    
    private func forceUpdateOrientation() {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                print("No window scene found")
                return
            }
            let orientations: UIInterfaceOrientationMask = isHorizontalLock ? .portrait : .allButUpsideDown
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations)) { error in
                print("Orientation update error: \(error.localizedDescription)")
            }
            
            // Также обновляем все window controllers
            for window in windowScene.windows {
                window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

struct RootView: View {
    @State private var status: LoaderStatus = .LOADING
    @ObservedObject private var nav: NavGuard = NavGuard.shared
    let url: URL = URL(string: "https://cosplaymaniapl.pro/write")!
    
    @ObservedObject private var orientationManager: OrientationManager = OrientationManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch status {
                case .LOADING, .ERROR:
                    switch nav.currentScreen {
                    case .LOADING:
                        Loading()
                            .edgesIgnoringSafeArea(.all)
                    case .MAIN:
                        ContentView()
                    }
                case .DONE:
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                        
                        GameLoader_1E6704B4Overlay(data: .init(url: url))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            Task {
                let result = await GameLoader_1E6704B4StatusChecker().checkStatus(url: url)
                if result {
                    orientationManager.unlockAllOrientations()
                    self.status = .DONE
                } else {
                    orientationManager.lockToPortrait()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            nav.currentScreen = .MAIN
                        }
                    }
                    self.status = .ERROR
                }
                print(result)
            }
        }
    }
}

#Preview {
    RootView()
}
