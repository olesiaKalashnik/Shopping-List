//
//  CurrentListEntity+CoreDataProperties.swift
//  Shopping List_v.2.0

//
//  Created by Olesia Kalashnik on 4/13/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CurrentListEntity {

    @NSManaged var markedAsCompleted: NSNumber
    @NSManaged var details: String?
    @NSManaged var inGlobalList: GlobalListEntity
    var isMarkedAsCompleted: Bool {
        get {
            return Bool(markedAsCompleted)
        }
        set {
            markedAsCompleted = NSNumber(bool: newValue)
        }
    }
}
