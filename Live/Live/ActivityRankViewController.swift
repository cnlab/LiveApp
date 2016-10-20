//
//  ActivityRankViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/20/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ActivityRankViewController: UIViewController {

    @IBOutlet var textView: UITextView?
    @IBOutlet var slider: UISlider?

    var popupViewController: ActivityPopupViewController?

    var rank: Double { get { return Double(slider?.value ?? 0) } }

    @IBAction func doneAction() {
        popupViewController?.rankDoneAction()
    }

}
