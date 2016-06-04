//
//  GlobalListEntity+CoreDataProperties.swift
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

extension GlobalListEntity {

    @NSManaged var title: String
    @NSManaged var selected: NSNumber
    // Anton: Consider using own type (or at least typealias) for category
    @NSManaged var category: String
    var isSelected: Bool {
        get {
            return Bool(selected)
        }
        set {
            selected = NSNumber(bool: newValue)
        }
    }

}
