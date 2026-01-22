import Foundation

enum AvailableScreens: Equatable {
    case LOADING
    case MAIN
}

enum LoaderStatus {
    case LOADING
    case DONE
    case ERROR
}

class NavGuard: ObservableObject {
    @Published var currentScreen: AvailableScreens = .LOADING
    static var shared: NavGuard = .init()
}
