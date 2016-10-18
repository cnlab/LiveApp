//
//  ValuesRankView.swift
//  Live
//
//  Created by Denis Bohm on 10/17/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class ValuesRankViewController : UIViewController {

    @IBOutlet var textView: UITextView?
    @IBOutlet var slider: UISlider?

    var valuesPopupViewController: ValuesPopupViewController?

    @IBAction func doneAction() {
        valuesPopupViewController?.rankDoneAction()
    }

}
