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

    var popupViewController: ActivityPopupViewController?

    @IBAction func okAction() {
        popupViewController?.thinkOkAction()
    }

}
