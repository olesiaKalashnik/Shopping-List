//
//  GlobalListTableViewController.swift
//  Shopping List_v.2.0
//
//  Created by Olesia Kalashnik on 3/25/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit
import CoreData

class GlobalListTableViewController: UITableViewController {
    
    var globalListData : GlobalList?  {
        didSet {
            shopLists.globalList.fetchItemsInGlobalList()
            self.globalListData? = shopLists.globalList
            self.tableView.reloadData()
        }
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let shopLists = ShopList()
    let searchController = UISearchController(searchResultsController: nil)
    var searchText : String?
    var categoryForNewItem : String? {
        didSet {
            print("categoryForNewItem: \(categoryForNewItem)")
        }
    }

    var filteredItems = [GlobalListEntity]()
    
    private var filteredItemsAsDictionary : [String:[GlobalListEntity]] {
        var filteredItemsAsDictionary = [String:[GlobalListEntity]]()
        for item in filteredItems {
            if filteredItemsAsDictionary[item.category] != nil {
                filteredItemsAsDictionary[item.category]?.append(item)
            } else {
                filteredItemsAsDictionary[item.category] = [item]
            }
        }
        return filteredItemsAsDictionary
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.searchText = searchText
        if let list = globalListData {
            filteredItems = list.items.filter { item in
                return item.title.lowercaseString.containsString(searchText.lowercaseString)
            }
                tableView.reloadData()
            }
        }
    
    func addNewItemToCategory(category: String) {
        if let newItem = searchText {
            if newItem != "" {
                print(category)
                if let globalItem = shopLists.globalList.getOrAddItem(newItem.lowercaseString, itemCategory: category)
                {
                    shopLists.currentList.addNewItemToCurrentListFromGlobalList(globalItem)
                }
            }
        }
        searchText = nil
    }
    
    @IBAction func dismissGlobalViewController() {
        let tmpController :UIViewController! = self.presentingViewController;
        
        self.dismissViewControllerAnimated(false, completion: {
            tmpController.dismissViewControllerAnimated(false, completion: nil);
        });
    }
    
    var managedContext: NSManagedObjectContext!
    
    // MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        shopLists.globalList.fetchItemsInGlobalList()
        shopLists.currentList.fetchItemsInCurrList()
        self.globalListData = shopLists.globalList
        
        if let list = globalListData {
            for item in list.items {
                item.selected = shopLists.currentList.items.contains({$0.inGlobalList == item})
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let list = globalListData {
            shopLists.globalList = list
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let list = globalListData?.categoriesAsList {
            return Array(Set(list)).count
        }
        return 0
    }
    
    private func countNumOfRowsInSection(listOfItems: [GlobalListEntity], section: Int) -> Int {
        let categoriesInList = listOfItems.map {$0.category}
        
        var counts = [String:Int]()
        for element in categoriesInList {
            counts[element] = (counts[element] ?? 0) + 1
        }
        var numberOfRowsInSections = [Int]()
        numberOfRowsInSections = counts.values.map {$0}
        
        if section < numberOfRowsInSections.count {
            return numberOfRowsInSections[section]
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = globalListData {
            if searchController.active && searchController.searchBar.text != "" {
                return countNumOfRowsInSection(filteredItems, section: section)
            } else {
                return countNumOfRowsInSection(list.items, section: section)
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let categorizedItems = globalListData?.asDictionary {
            return categorizedItems.keys.map{$0}[section]
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if (filteredItems.isEmpty && searchText != "") {
            view.hidden = false
        } else {
            view.hidden = true
        }
    }
    
    @IBAction func addItemButton(sender: UIButton) {
        if let category = categoryForNewItem {
            addNewItemToCategory(category)
        }
        printWhenButtonTouched(sender)
    }
    
    func printWhenButtonTouched(sender: UIButton) {
        print("Add button was touched")
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if searchController.active && searchText != "" && filteredItems.isEmpty {
            return 44.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cellIdentifier = "sectionFooter"
        let footerView = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? FooterTableViewCell
        if let list = globalListData {
            categoryForNewItem = list.categoriesAsList[section]
            if let item = searchText {
                footerView?.addButtonOutlet.setTitle("Add \(item.lowercaseString) to \(categoryForNewItem)", forState: .Normal)
                return footerView
            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GlobalItemReuseIdentifier", forIndexPath: indexPath) as! GlobaListlItemTableViewCell
        // Configure the cell...
        
        if searchController.active && searchController.searchBar.text != "" {
            let filteredItemsGrouped = filteredItemsAsDictionary.values.map {$0} as [[GlobalListEntity]]
            cell.globalItem = filteredItemsGrouped[indexPath.section][indexPath.row]
            
        } else {
            
            if let itList = globalListData?.groupedItemsAsList {
                cell.globalItem = itList[indexPath.section][indexPath.row]
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let globalListGrouped = shopLists.globalList.groupedItemsAsList
            let itemToBeRemovedFromGlobalList = globalListGrouped[indexPath.section][indexPath.row]
            
            // Find and delete item from Current List
            let itemsToBeRemovedInCurrList = shopLists.currentList.items.filter { $0.inGlobalList == itemToBeRemovedFromGlobalList }
            if let itemToBeRemovedFromCurrList = itemsToBeRemovedInCurrList.first  {
                shopLists.currentList.deleteItemFromManagedContext(itemToBeRemovedFromCurrList)
            }
            
            // Delete item from Global List
            shopLists.globalList.deleteItemFromManagedContext(itemToBeRemovedFromGlobalList)
            
            tableView.reloadData()
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }
        if segue.identifier == "show current list" {
            if let currentListTBV = segue.destinationViewController as? CurrentListTableViewController  {
                if let globalList = globalListData {
                    currentListTBV.shopLists.globalList = globalList
                }
            }
        }
    }
}

extension GlobalListTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
