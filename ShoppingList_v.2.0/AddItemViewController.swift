//
//  AddItemViewController.swift
//  Shopping List_v.2.0
//
//  Created by Olesia Kalashnik on 3/21/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit
import CoreData

class AddItemViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource {

    let shopLists = ShopList()
    
    @IBOutlet weak var newItemTextField: UITextField! {
        didSet {
            newItemTextField.delegate = self
        }
    }
    @IBOutlet weak var categoryPickerView: UIPickerView! {
        didSet {
            categoryPickerView.delegate = self
            categoryPickerView.dataSource = self
        }
    }
    
    var currentList = CurrentList()
    var globalList = GlobalList()
    let allCategoriesNames = ["None", "Baked Goods", "Beauty & Health", "Beverages", "Canned Goods", "Dairy", "Dressings", "Fruits & Veggies", "Household & Cleaning", "Meat & Fish", "Snacks", "Sweets"]
    
    func addNewItem() {
        if let newItem = newItemTextField.text {
            if newItem != "" {
                let selectedCategoryName = allCategoriesNames[categoryPickerView.selectedRowInComponent(0)]
                
                if let globalItem = globalList.getOrAddItem(newItem, itemCategory: selectedCategoryName) {
                    currentList.addNewItemToCurrentListFromGlobalList(globalItem)
                }
            }
        }
        newItemTextField.text = nil
    }
    
    // MARK: - pickerView delegate methods
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allCategoriesNames.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allCategoriesNames[row]
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addNewItem()
        
        textField.resignFirstResponder()
        return true
    }
    
    func back(sender: UIBarButtonItem) {
        performSegueWithIdentifier("show global list", sender: self)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(AddItemViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        shopLists.currentList.fetchItemsInCurrList()
        shopLists.globalList.fetchItemsInGlobalList()
        self.currentList = shopLists.currentList
        self.globalList = shopLists.globalList
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        shopLists.globalList.saveManagedContext()
        shopLists.currentList.saveManagedContext()
        shopLists.globalList = self.globalList
        shopLists.currentList = self.currentList
    }
    
    // helper method for printing out contents of both lists
    func printOutContentsOfLists() {
        print("\n Items in current list: ")
        let items = currentList.items.map{$0.inGlobalList.title}
        let categories = currentList.items.map {$0.inGlobalList.category}
        var itemsWithCategories = [String:String]()
        for (key, value) in zip(items, categories) {
            itemsWithCategories[key] = value
        }
        print(itemsWithCategories)
        
        print("\n Items in global list: ")
        let globItems = globalList.items.map{$0.title}
        let globCategories = globalList.items.map {$0.category}
        var globItemsWithCategories = [String:String]()
        for (key, value) in zip(globItems, globCategories) {
            globItemsWithCategories[key] = value
        }
        print(globItemsWithCategories)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destination = segue.destinationViewController as UIViewController
        if let navController = destination as? UINavigationController {
            destination = navController.visibleViewController!
        }
        if let globalListTVC = destination as? GlobalListTableViewController {
            if segue.identifier == "show global list" {
                globalListTVC.globalListData = self.globalList
            }
        }
    }
    
}

