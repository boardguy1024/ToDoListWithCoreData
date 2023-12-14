//
//  ToDoListWithCoreDataApp.swift
//  ToDoListWithCoreData
//
//  Created by paku on 2023/12/14.
//

import SwiftUI

@main
struct ToDoListWithCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
