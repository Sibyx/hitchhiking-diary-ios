import Foundation
import AppIntents

struct HitchhikingDiaryShortcutProvider: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        
        AppShortcut(
            intent: AddTripRecord(),
            phrases: [
                "Save trip record"
            ],
            shortTitle: "Save trip record",
            systemImageName: "mappin.circle"
        )   
        
        AppShortcut(
            intent: CreateTripStoryURL(),
            phrases: [
                "Create Trip Story URL"
            ],
            shortTitle: "Create Trip Story URL",
            systemImageName: "photo"
        )
    }
}

