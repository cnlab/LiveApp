//
//  SurveyIntroductionViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyIntroductionViewController: TrackerViewController {

    @IBOutlet var tipView: UIView?
    
    var shareCallback: (() -> Void)? = nil
    var aboutCallback: (() -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        tipView?.isHidden = LiveManager.shared.shareDataWithResearchers.value
    }

    @IBAction func share() {
        if let shareCallback = shareCallback {
            Tracker.sharedInstance().action(category: "Survey", name: "Share")
            shareCallback()
        }
    }

    @IBAction func about() {
        if let aboutCallback = aboutCallback {
            Tracker.sharedInstance().action(category: "Survey", name: "About")
            aboutCallback()
        }
    }

}
