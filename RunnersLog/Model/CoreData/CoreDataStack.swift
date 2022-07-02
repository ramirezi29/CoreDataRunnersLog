//
//  CoreDataStack.swift
//  RunnersLog
//
//  Created by Ivan Ramirez on 1/26/22.
//

import Foundation
import CoreData

enum CoreDataStack {

    static let container: NSPersistentContainer = {
        //This line of code grabs the app name
        let appName = Bundle.main.object(forInfoDictionaryKey: (kCFBundleNameKey as String)) as! String

        let container = NSPersistentContainer(name: appName)
        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    
    static var managedObjectContext: NSManagedObjectContext {
        return container.viewContext
    }

    static func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                NSLog("Error saving context \(error.localizedDescription)")
            }
        }
    }
    
}


