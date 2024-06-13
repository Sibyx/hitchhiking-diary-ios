//
//  Hitchhiking_DiaryApp.swift
//  Hitchhiking Diary
//
//  Created by Jakub Dubec on 13/06/2024.
//

import SwiftUI
import SwiftData

@main
struct Hitchhiking_DiaryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
