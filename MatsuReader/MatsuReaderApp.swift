//
//  MatsuReaderApp.swift
//  MatsuReader
//
//  Created by user on 2022/08/02.
//

import SwiftUI

@main
struct MatsuReaderApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        // disable disk cache for privacy
        URLCache.shared.diskCapacity = 0
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
