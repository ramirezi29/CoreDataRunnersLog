//
//  EntryController.swift
//  RunnersLog
//
//  Created by Ivan Ramirez on 1/26/22.
//

import CoreData

class EntryController {
    
    static let shared = EntryController()
    
    private lazy var fetchRequest: NSFetchRequest<Entry> = {
        
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        
        // if false, then all the entries are not fetched/presented to the user
        request.predicate = NSPredicate(value: true)
        
        return request
    }()
    
    //Array of fetched entries
    var fetchedEntries: [Entry] {
        do {
            return try CoreDataStack.managedObjectContext.fetch(self.fetchRequest)
        } catch {
            print("Error fetching entries: \(error.localizedDescription)")
            return []
        }
    }
    
    func createEntry(entry: Entry) {
        CoreDataStack.saveContext()
    }
    
    func updateEntry(entry: Entry, trackLocation: Bool, distance: String) {
        entry.trackLocation = trackLocation
        entry.distance = distance
        
        CoreDataStack.saveContext()
    }
    
    func sortEntries(ascending: Bool) {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: ascending)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            _ =  try CoreDataStack.managedObjectContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /*
     Batch delete function taken from the following website.
     https://www.advancedswift.com/batch-delete-everything-core-data-swift/
     */
    func deleteEverything() {
        
        // Specify a batch to delete with a fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "Entry")
        
        // Create a batch delete request for the
        // fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        
        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the
        // deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs
        
        // Get a reference to a managed object context
        let context = CoreDataStack.managedObjectContext
        
        // Perform the batch delete
        do {
            let batchDelete = try context.execute(deleteRequest)
            as? NSBatchDeleteResult
            
            guard let deleteResult = batchDelete?.result
                    as? [NSManagedObjectID]
            else { return }
            
            let deletedObjects: [AnyHashable: Any] = [
                NSDeletedObjectsKey: deleteResult
            ]
            
            // Merge the delete changes into the managed
            // object context
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: deletedObjects,
                into: [context]
            )
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
