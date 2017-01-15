//
//  SurveyIntroductionViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyIntroductionViewController: UIViewController {

    @IBOutlet var tipView: UIView?
    
    var shareCallback: ((Void) -> Void)? = nil
    var aboutCallback: ((Void) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        tipView?.isHidden = LiveManager.shared.shareDataWithResearchers
    }

    open override func viewDidLayoutSubviews() {
        Layout.vertical(viewController: self)
        if let tipView = tipView {
            Layout.vertical(viewController: self, view: tipView, flexibleView: nil, insets: UIEdgeInsets())
        }
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
