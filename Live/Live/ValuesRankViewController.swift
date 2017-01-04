//
//  ValuesRankView.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ValuesRankViewController: UIViewController {

    @IBOutlet var textView: UITextView?
    @IBOutlet var slider: UISlider?

    var popupViewController: ValuesPopupViewController?

    var rank: Double { get { return Double(slider?.value ?? 0) } }

    @IBAction func doneAction() {
        popupViewController?.rankDoneAction()
    }

}
