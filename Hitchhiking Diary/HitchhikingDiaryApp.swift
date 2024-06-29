import SwiftUI
import SwiftData

@main
struct HitchhikingDiaryApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(appState.modelContainer)
        }
    }
}
