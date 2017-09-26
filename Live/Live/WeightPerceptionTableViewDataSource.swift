//
//  WeightPerceptionTableViewDataSource.swift
//  Live
//
//  Created by Denis Bohm on 8/25/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class WeightPerceptionTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    let optionsText = ["about right", "heavier than I would like", "lighter than I would like"]
    var option: Int? = nil
    var valueChangedCallback: (() -> Void)? = nil
    
    var weightPerception: String? {
        get {
            if let option = self.option {
                return optionsText[option]
            }
            return nil
        }
        set(value) {
            if let value = value, let index = optionsText.index(of: value) {
                option = index
            } else {
                option = nil
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // This was put in mainly for my own unit testing
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsText.count
    }

    func isSelected(row: Int) -> Bool {
        return (option != nil) && (option! == row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
        let row = indexPath.row
        cell.textLabel?.text = optionsText[row]
        cell.accessoryType = isSelected(row: row) ? .checkmark : .none
        cell.textLabel?.textColor = isSelected(row: row) ? UIColor.black : UIColor.lightGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if (option != nil) && (option! == row) {
            self.option = nil
        } else {
            self.option = row
        }
        
        tableView.reloadData()

        if let valueChangedCallback = valueChangedCallback {
            valueChangedCallback()
        }
    }

}
