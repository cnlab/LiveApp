//
//  ImportanceViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/28/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ImportanceViewController: UIViewController {

    class DataSource : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

        var values: [String] = []

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return values.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return values[row]
        }

        func newLabel() -> UILabel {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16.0)
            label.textAlignment = .center
            return label
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = view as? UILabel ?? newLabel()
            label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            return label
        }

    }

    @IBOutlet var valuePickerView: UIPickerView?

    var popupViewController: ImportancePopupViewController?

    var dataSource: DataSource = DataSource()

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
