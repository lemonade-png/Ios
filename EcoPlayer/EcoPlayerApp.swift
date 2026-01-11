import SwiftUI

@main
struct EcoPlayerApp: App {
    init() {
        BatteryOptimizer.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
