//
//  GlobaListlItemTableViewCell.swift
//  Shopping List_v.2.0
//
//  Created by Olesia Kalashnik on 3/25/16.
//  Copyright © 2016 Olesia Kalashnik. All rights reserved.
//

import UIKit

class GlobaListlItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    
    var globalItem : GlobalListEntity? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var checkboxLabel: CheckboxButton!
    
    @IBAction func checkboxButton(sender: CheckboxButton) {
        sender.selected = !sender.selected
        if let item = globalItem {
            item.selected = sender.selected
        }
    }
    
    func updateUI() {
        itemNameLabel.text = nil
        if let item = self.globalItem {
            itemNameLabel.text = item.title
            checkboxLabel.selected = item.isSelected
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
