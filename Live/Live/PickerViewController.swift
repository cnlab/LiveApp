//
//  PickerViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    @IBOutlet var pickerView: UIPickerView?

    var dataSource: StringArrayPickerViewDataSource = StringArrayPickerViewDataSource()

    var values: [String] = []

    func prepare(values: [String], value: String?) {
        self.values = values

        dataSource.values = values
        pickerView?.dataSource = dataSource
        pickerView?.delegate = dataSource
        pickerView?.reloadAllComponents()
        var row = values.count / 2 - 1
        if let value = value {
            if let index = values.index(of: value) {
                row = index
            }
        }
        pickerView?.selectRow(row, inComponent: 0, animated: false)
    }

    var value: String {
        get {
            let row = pickerView?.selectedRow(inComponent: 0) ?? 0
            return values[row]
        }
    }

    @IBAction func doneAction() {
        if let pickerPopupViewController = parent as? PickerPopupViewController {
            pickerPopupViewController.closeAction()
        }
    }

}
