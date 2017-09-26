//
//  MessageTableViewDataSource.swift
//  Live
//
//  Created by Denis Bohm on 8/28/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class MessageTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    @IBInspectable open var reusableCellIdentifier: String = "MessageCell"
    
    let text: String = "Sample"
    var isChecked: Bool = false
    var valueChangedCallback: (() -> Void)? = nil
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func isSelected(row: Int) -> Bool {
        return isChecked
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier)!
        cell.textLabel?.text = text
        cell.accessoryType = isChecked ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isChecked = !self.isChecked
        
        tableView.reloadData()
        
        if let valueChangedCallback = valueChangedCallback {
            valueChangedCallback()
        }
    }
    
}
