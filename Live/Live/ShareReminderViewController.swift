//
//  ShareReminderViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/5/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class ShareReminderViewController: TrackerViewController {

    var popupViewController: ShareReminderPopupViewController?

    @IBAction func doneAction() {
        popupViewController?.okAction()
    }
    
}
