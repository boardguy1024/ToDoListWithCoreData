//
//  Persistence.swift
//  ToDoListWithCoreData
//
//  Created by paku on 2023/12/14.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoDataModel")
        if inMemory {
            // Preview用であり、PersistentStoreがDiskではなくMemory上に作成されることを意味する
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // 親に変更が生じたら、その内容を自動的に自分にマージするか否か
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
