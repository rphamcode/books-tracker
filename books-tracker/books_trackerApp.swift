//
//  books_trackerApp.swift
//  books-tracker
//
//  Created by Pham on 4/25/23.
//

import SwiftUI

@main
struct books_trackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
