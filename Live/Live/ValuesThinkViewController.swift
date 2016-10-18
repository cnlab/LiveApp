//
//  ValuesThinkView.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ValuesThinkViewController : UIViewController {

    @IBOutlet var textView: UITextView?

    var valuesPopupViewController: ValuesPopupViewController?

    @IBAction func okAction() {
        valuesPopupViewController?.thinkOkAction()
    }

}
