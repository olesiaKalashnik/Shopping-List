//
//  Lists.swift
//  Shopping List_v.2.0
//
//  Created by Olesia Kalashnik on 3/22/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ShoppingList {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func createGlobalEntity(itemName: String, itemCategory: String) -> GlobalListEntity? {
        let managedContext = appDelegate.managedObjectContext
        let entityGlobal = NSEntityDescription.entityForName("GlobalListEntity", inManagedObjectContext:managedContext)
        if let globEntityDescription = entityGlobal {
            let globalItem = GlobalListEntity(entity: globEntityDescription, insertIntoManagedObjectContext: managedContext)
            globalItem.title = itemName
            globalItem.category = itemCategory
            globalItem.selected = true
            return globalItem
        }
        return nil
    }
    
    func createCurrentEntity(globalEntity: GlobalListEntity) -> CurrentListEntity? {
        let managedContext = appDelegate.managedObjectContext
        let entityCurrent =  NSEntityDescription.entityForName("CurrentListEntity", inManagedObjectContext:managedContext)
        if let currentEntityDescription = entityCurrent {
            let currItem = CurrentListEntity(entity: currentEntityDescription, insertIntoManagedObjectContext: managedContext)
            currItem.inGlobalList.title = globalEntity.title
            currItem.markedAsCompleted = false
            currItem.details = ""
            currItem.inGlobalList = globalEntity
            return currItem
        }
        return nil
    }
    
    func saveCurrentEntityInManagedContext(currentEntity:CurrentListEntity, currentList : CurrentList) {
        let managedContext = appDelegate.managedObjectContext
        do {
            try managedContext.save()
            currentList.items.append(currentEntity)
            print("Saved current item \(currentEntity.inGlobalList.title)")
            
        } catch let error as NSError  {
            print("Could not save cuttent item \(currentEntity.inGlobalList.title) \(error), \(error.userInfo)")
        }
    }
    
    func saveGlobalEntityInManagedContext(globalEntity:GlobalListEntity, globalList : GlobalList) {
        let managedContext = appDelegate.managedObjectContext
        do {
            try managedContext.save()
            globalList.items.append(globalEntity)
            print("Saved global item \(globalEntity.title)")
            
        } catch let error as NSError  {
            print("Could not save global item \(globalEntity.title) \(error), \(error.userInfo)")
        }
    }
    
    func addNewItemToBothLists(itemName: String, itemCategory: String, currentList: CurrentList, globalList: GlobalList) {
        if let globalEntity = createGlobalEntity(itemName, itemCategory: itemCategory) {
            if let currItem = createCurrentEntity(globalEntity) {
                saveGlobalEntityInManagedContext(globalEntity, globalList: globalList)
                saveCurrentEntityInManagedContext(currItem, currentList: currentList)
            }
        }
    }
    
    func unique<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var addedDict = [T:Bool]()
        return source.filter { addedDict.updateValue(true, forKey: $0) == nil }
    }
    
    func saveManagedContext() {
        let managedContext = appDelegate.managedObjectContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Couldn't save updates: \(error.userInfo)")
        }
    }
    
}

class CurrentList : ShoppingList {
    
    var items = [CurrentListEntity]()
    
    // Methods for CurrentList data representation
    var asDictionary : [String : [CurrentListEntity]] {
        var answerDict = [String:[CurrentListEntity]]()
        var itemsInCategory = [CurrentListEntity]()
        let categories = unique(items.map {$0.inGlobalList.category})
        for cat in categories {
            itemsInCategory = self.items.filter {$0.inGlobalList.category == cat}
            answerDict[cat] = itemsInCategory
        }
        return answerDict
    }
    
    var categoriesAsList : [String] {
        return self.asDictionary.keys.map {$0}
    }
    
    var groupedItemsAsList : [[CurrentListEntity]] {
        return self.asDictionary.values.map { $0 }
    }
    
    // Methods for adding items to CurrentList and updating it
    
    func addNewItemToCurrentListFromGlobalList(globalEntity: GlobalListEntity) {
        if !self.items.contains({$0.inGlobalList.title == globalEntity.title && $0.inGlobalList.category == globalEntity.category}) {
            if let currentEntity = createCurrentEntity(globalEntity) {
                saveCurrentEntityInManagedContext(currentEntity, currentList: self)
            }
        }
    }
    
    func updateCurrentListWithSelectedGlobalItems(selectedGlobalItems: [GlobalListEntity]?) {
        if let globalItems = selectedGlobalItems {
            for item in globalItems {
                if !self.items.contains( { $0.inGlobalList.title == item.title && $0.inGlobalList.category == item.category } ) {
                    self.addNewItemToCurrentListFromGlobalList(item)
                }
            }
        }
    }
    
    func getSelectedItems() -> [CurrentListEntity]?{
        return items.filter {$0.isMarkedAsCompleted}
    }
    
    func deleteItemFromManagedContext(currentItemToBeDeleted: CurrentListEntity) {
        let managedContext = appDelegate.managedObjectContext
        managedContext.deleteObject(currentItemToBeDeleted as NSManagedObject)
        fetchItemsInCurrList()
        saveManagedContext()
        
    }
    
    func fetchItemsInCurrList() {
        let managedContext = appDelegate.managedObjectContext
        let currEntDescription = NSEntityDescription.entityForName("CurrentListEntity", inManagedObjectContext: managedContext)
        let request = NSFetchRequest()
        request.entity = currEntDescription
        do {
            let result = try managedContext.executeFetchRequest(request)
            items = result as! [CurrentListEntity]
            
        } catch let error as NSError {
            print("Could not find item: \(error.userInfo)")
        }
    }
}

class GlobalList : ShoppingList {
    var items = [GlobalListEntity]()
    
    // Methods for GlobalList data representation
    var asDictionary : [String : [GlobalListEntity]] {
        var answerDict = [String:[GlobalListEntity]]()
        var itemsInCategory = [GlobalListEntity]()
        let categories = unique(self.items.map {$0.category})
        for cat in categories {
            itemsInCategory = self.items.filter {$0.category == cat}
            answerDict[cat] = itemsInCategory
        }
        return answerDict
    }
    
    var categoriesAsList : [String] {
        let dict = self.asDictionary
        return dict.keys.map {$0}
    }
    
    var groupedItemsAsList : [[GlobalListEntity]] {
        let categorizedItems = self.asDictionary
        return categorizedItems.values.map { $0 }
    }
    
    // Methods for adding items to GlobalList and updating it
    func getSelectedGlobalItems() -> [GlobalListEntity]? {
        return items.filter { $0.isSelected }
    }
    
    func getOrAddItem(itemName: String, itemCategory: String) -> GlobalListEntity? {
        if let globalItem = self.items.filter( { $0.title == itemName && $0.category == itemCategory } ).first {
            return globalItem
        } else {
            if let globalEntity = self.createGlobalEntity(itemName, itemCategory: itemCategory) {
                saveGlobalEntityInManagedContext(globalEntity, globalList: self)
                return globalEntity
            }
            return nil
        }
    }
    
    func deleteItemFromManagedContext(globalItemToBeDeleted: GlobalListEntity) {
        let managedContext = appDelegate.managedObjectContext
        managedContext.deleteObject(globalItemToBeDeleted as NSManagedObject)
        fetchItemsInGlobalList()
        saveManagedContext()
    }
    
    func fetchItemsInGlobalList() {
        let managedContext = appDelegate.managedObjectContext
        let globalEntDescription = NSEntityDescription.entityForName("GlobalListEntity", inManagedObjectContext: managedContext)
        let request = NSFetchRequest()
        request.entity = globalEntDescription
        do {
            let result = try managedContext.executeFetchRequest(request)
            items = result as! [GlobalListEntity]
            
        } catch let error as NSError {
            print("Could not fetch items in global list: \(error.userInfo)")
        }
    }
    
}