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

    var popupViewController: ValuesPopupViewController?

    @IBAction func okAction() {
        popupViewController?.thinkOkAction()
    }

}
