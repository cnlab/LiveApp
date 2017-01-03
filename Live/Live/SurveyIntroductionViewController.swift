//
//  SurveyIntroductionViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyIntroductionViewController: UIViewController {

    var shareCallback: ((Void) -> Void)? = nil
    var aboutCallback: ((Void) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewDidLayoutSubviews() {
        Layout.vertical(viewController: self)
    }

    @IBAction func share() {
        if let shareCallback = shareCallback {
            shareCallback()
        }
    }

    @IBAction func about() {
        if let aboutCallback = aboutCallback {
            aboutCallback()
        }
    }

}
