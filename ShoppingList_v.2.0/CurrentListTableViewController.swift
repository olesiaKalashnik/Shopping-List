//
//  CurrentListTableViewController.swift
//  Shopping List_v.2.0
//
//  Created by Olesia Kalashnik on 3/25/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit
import CoreData

class CurrentListTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let shopLists = ShopList()
    var currentListData : CurrentList?  {
        didSet {
            shopLists.currentList.fetchItemsInCurrList()
            self.currentListData = shopLists.currentList
            hideOutlet?.enabled = currentListData?.items.count > 0
            self.tableView.reloadData()
        }
    }
        
    @IBOutlet weak var hideOutlet: UIBarButtonItem!
    
    @IBAction func hideCompletedItems(sender: UIBarButtonItem) {
        if let list = currentListData {
            if let listToBeDeleted = list.getSelectedItems() {
                for item in listToBeDeleted {
                    item.inGlobalList.isSelected = false
                    list.deleteItemFromManagedContext(item)
                }
                self.hideOutlet.enabled = list.items.count > 0
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Controller Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        shopLists.currentList.fetchItemsInCurrList()
        self.currentListData = shopLists.currentList
        if let currList = currentListData {
            let selectedGlobalItems = shopLists.globalList.getSelectedGlobalItems()
            currList.updateCurrentListWithSelectedGlobalItems(selectedGlobalItems)
        }
        hideOutlet?.enabled = currentListData?.items.count > 0
        currentListData?.fetchItemsInCurrList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let list = currentListData {
            shopLists.currentList = list
        }
        shopLists.currentList.saveManagedContext()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let list = currentListData?.categoriesAsList {
            return Array(Set(list)).count
        }
        return 0
   }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = currentListData {
            let categoriesInList = list.items.map {$0.inGlobalList.category}
            
            var counts = [String:Int]()
            for element in categoriesInList {
                counts[element] = (counts[element] ?? 0) + 1
            }
            var numberOfRowsInSections = [Int]()
            numberOfRowsInSections = counts.values.map {$0}
            
            if section < numberOfRowsInSections.count {
                return numberOfRowsInSections[section]
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let categorizedItems = currentListData?.asDictionary {
            return categorizedItems.keys.map{$0}[section]
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrentItemReuseIdentifier", forIndexPath: indexPath) as! CurrentListItemTableViewCell
        // Configure the cell...
        if let itList = currentListData?.groupedItemsAsList {
            cell.currItem = itList[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }
        
        if segue.identifier == "show library" {
            if let globalListTBV = destination as? GlobalListTableViewController {
                if let ppc = globalListTBV.popoverPresentationController {
                    ppc.delegate = self
                    if let currList = currentListData {
                        globalListTBV.shopLists.currentList = currList
                    }
                }
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None //don't adapt, suppress the modal stlyle
    }

}
