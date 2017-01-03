//
//  PickerPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class PickerPopupViewController: PopupViewController {

    var pickerViewController: PickerViewController? {
        get {
            return childViewControllers.first as? PickerViewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func show(inView parent: UIView, values: [String], value: String?, action: ((Void) -> Void)?) {
        guard let pickerViewController = pickerViewController else {
            return
        }
        let dataSource = StringArrayPickerViewDataSource(values: values)
        pickerViewController.prepare(dataSource: dataSource, selections: [value], action: action)
        super.show(inView: parent, animated: true)
    }

    func show(inView parent: UIView, feet: Int?, inches: Int?, action: ((Void) -> Void)?) {
        guard let pickerViewController = pickerViewController else {
            return
        }
        let dataSource = HeightPickerViewDataSource()
        pickerViewController.prepare(dataSource: dataSource, selections: [feet, inches], action: action)
        super.show(inView: parent, animated: true)
    }
    
}
