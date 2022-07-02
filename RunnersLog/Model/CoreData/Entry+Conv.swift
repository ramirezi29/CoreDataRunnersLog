//
//  Entry+Conv.swift
//  RunnersLog
//
//  Created by Ivan Ramirez on 1/26/22.
//

import CoreData

extension Entry {
    @discardableResult

    convenience init(distance: String,trackLocation: Bool, date: Date, context: NSManagedObjectContext = CoreDataStack.managedObjectContext) {

        self.init(context: context)
        self.distance = distance
        self.trackLocation = trackLocation
        self.date = date
    }
}
