//
//  CurrentListItemTableViewCell.swift
//  Shopping List_v.2.0
//
//  Created by Olesia Kalashnik on 3/25/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class CurrentListItemTableViewCell: UITableViewCell {
    
    var currItem : CurrentListEntity? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var checkboxOutlet: CheckboxButton!
    
    @IBAction func checkboxButton(sender: CheckboxButton) {
        sender.selected = !sender.selected
        if let item = currItem {
            item.markedAsCompleted = sender.selected
        }
    }
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    func updateUI() {
        itemNameLabel.text = nil
        if let item = self.currItem {
            itemNameLabel.text = item.inGlobalList.title
            checkboxOutlet.selected = item.isMarkedAsCompleted
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
