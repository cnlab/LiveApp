//
//  PickerViewDataSource.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class PickerViewDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    let components: [[Any?]]
    let suffixes: [String]

    init(components: [[Any?]], suffixes: [String]) {
        self.components = components
        self.suffixes = suffixes

        super.init()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return components[component].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let value = components[component][row] {
            let suffix = suffixes[component]
            return "\(value)\(suffix)"
        }
        return "-"
    }

    func index(of value: Any?, forComponent component: Int) -> Int? {
        return nil
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
