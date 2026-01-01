//
//  CoreDataStack.swift
//  GoForLaunchApp
//
//  Created by Gokhan on 13.10.2025.
//

import CoreData

public final class CoreDataStack {

    public static let shared = CoreDataStack()

    public let persistentContainer: NSPersistentContainer
    public var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    public init() {
        persistentContainer = NSPersistentContainer(name: "GoForLaunchApp")
        persistentContainer.loadPersistentStores { _, error in
            if let error { fatalError("Store load error: \(error)") }
        }
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.automaticallyMergesChangesFromParent = true
    }

    public func saveIfNeeded() throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }
}

