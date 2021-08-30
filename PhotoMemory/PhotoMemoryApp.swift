//
//  PhotoMemoryApp.swift
//  PhotoMemory
//
//  Created by Andres Marquez on 2021-08-12.
//

import SwiftUI

@main
struct PhotoMemoryApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
