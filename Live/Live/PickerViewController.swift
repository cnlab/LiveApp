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

    var dataSource: PickerViewDataSource = StringArrayPickerViewDataSource(values: [])
    var action: ((Void) -> Void)?

    func prepare(dataSource: PickerViewDataSource, selections: [Any?], action: ((Void) -> Void)?) {
        self.dataSource = dataSource
        self.action = action

        guard let pickerView = pickerView else {
            return
        }

        pickerView.dataSource = dataSource
        pickerView.delegate = dataSource
        pickerView.reloadAllComponents()

        let count = dataSource.numberOfComponents(in: pickerView)
        for component in 0 ..< count {
            var row = dataSource.components[component].count / 2 - 1
            if let selection = selections[component] {
                let index = dataSource.index(of: selection, forComponent: component)
                if let index = index {
                    row = index
                }
            }
            pickerView.selectRow(row, inComponent: component, animated: false)
        }
    }

    var selections: [Any?] {
        get {
            guard let pickerView = pickerView else {
                return []
            }
            var selections: [Any?] = []
            let count = dataSource.numberOfComponents(in: pickerView)
            for component in 0 ..< count {
                let row = pickerView.selectedRow(inComponent: component)
                let value = dataSource.components[component][row]
                selections.append(value)
            }
            return selections
        }
    }

    @IBAction func doneAction() {
        if let pickerPopupViewController = parent as? PickerPopupViewController {
            pickerPopupViewController.closeAction()
            if let action = action {
                action()
            }
        }
    }

}
