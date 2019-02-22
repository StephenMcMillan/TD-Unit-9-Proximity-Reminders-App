//
//  CoreDataManager.swift
//  Proximity Reminders
//
//  Created by Stephen McMillan on 22/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private static let modelName = "Reminder"
    
    public static let sharedManager = CoreDataManager()
    
    // Stop other instances being created given that this is using the singleton pattern
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let persistentContainer = NSPersistentContainer(name: CoreDataManager.modelName)
        persistentContainer.loadPersistentStores() { description, error in
            if let error = error {
                // We may have an error when loading the persistent store.
                fatalError("Unable to load the persistent store.")
            }
        }
        
        return persistentContainer
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    
}
