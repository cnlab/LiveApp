//
//  ActivityThinkViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/20/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ActivityThinkViewController: UIViewController {

    @IBOutlet var textView: UITextView?
    @IBOutlet var importantButton: UIButton?
    @IBOutlet var unimportantButton: UIButton?

    var popupViewController: ActivityPopupViewController?

    var rank: Double {
        get {
            if importantButton?.isSelected ?? false {
                return +1.0
            }
            if unimportantButton?.isSelected ?? false {
                return -1.0
            }
            return 0.0
        }
        set(value) {
            importantButton?.isSelected = false
            unimportantButton?.isSelected = false
        }
    }
    
    @IBAction func importantAction() {
        importantButton?.isSelected = true
        unimportantButton?.isSelected = false
        popupViewController?.saveAction()
    }
    
    @IBAction func unimportantAction() {
        unimportantButton?.isSelected = true
        importantButton?.isSelected = false
        popupViewController?.saveAction()
    }
    
}
