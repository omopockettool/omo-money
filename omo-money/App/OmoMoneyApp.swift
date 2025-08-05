//
//  OmoMoneyApp.swift
//  omo-money
//
//  Created by Dennis Chicaiza A on 05/8/2025.
//

import SwiftUI
import SwiftData

@main
struct OmoMoneyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HomeGroup.self,
            Entry.self,
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: URL.documentsDirectory.appending(path: "omo-money.store")
        )

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
