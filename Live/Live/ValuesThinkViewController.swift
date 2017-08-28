//
//  ValuesThinkView.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ValuesThinkViewController: UIViewController {

    @IBOutlet var textView: UITextView?
    @IBOutlet var importantButton: UIButton?
    @IBOutlet var unimportantButton: UIButton?

    var popupViewController: ValuesPopupViewController?

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
            if value > 0.0 {
                importantButton?.isSelected = true
                unimportantButton?.isSelected = false
                return
            }
            if value < 0.0 {
                importantButton?.isSelected = false
                unimportantButton?.isSelected = true
                return
            }
            importantButton?.isSelected = false
            unimportantButton?.isSelected = false
        }
    }

    @IBAction func importantAction() {
        if importantButton?.isSelected ?? false {
            unimportantButton?.isSelected = false
        }
    }
    
    @IBAction func unimportantAction() {
        if unimportantButton?.isSelected ?? false {
            importantButton?.isSelected = false
        }
    }
    
    @IBAction func saveAction() {
        popupViewController?.saveAction()
    }

}
