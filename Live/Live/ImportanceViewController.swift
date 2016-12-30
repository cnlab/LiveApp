//
//  ImportanceViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/28/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ImportanceViewController: UIViewController {

    @IBOutlet var valuePickerView: UIPickerView?

    var popupViewController: ImportancePopupViewController?

    var dataSource: StringArrayPickerViewDataSource = StringArrayPickerViewDataSource()

    var valuesArray: [String] = []
    var values: [String] {
        get {
            return valuesArray
        }
        set {
            valuesArray = newValue

            dataSource.values = values
            valuePickerView?.dataSource = dataSource
            valuePickerView?.delegate = dataSource
            valuePickerView?.reloadAllComponents()
            let row = values.count / 2 - 1
            valuePickerView?.selectRow(row, inComponent: 0, animated: false)
        }
    }

    var value: String {
        get {
            let row = valuePickerView?.selectedRow(inComponent: 0) ?? 0
            return valuesArray[row]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneAction() {
        popupViewController?.importanceOkAction()
    }

}
