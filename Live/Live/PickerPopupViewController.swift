//
//  PickerPopupViewController.swift
//  Live
//
//  Created by Denis Bohm on 12/29/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class PickerPopupViewController: PopupViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func show(inView parent: UIView, values: [String], value: String?) {
        if let pickerViewController = childViewControllers.first as? PickerViewController {
            pickerViewController.prepare(values: values, value: value)
            super.show(inView: parent, animated: true)
        }
    }
    
}
