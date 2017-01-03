//
//  SurveyViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/26/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyViewController: UIViewController {

    @IBOutlet var introductionView: UIView?
    @IBOutlet var formView: UIView?
    @IBOutlet var nextView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func expose(view: UIView?) {
        introductionView?.isHidden = view != introductionView
        formView?.isHidden = view != formView
        nextView?.isHidden = view != nextView
    }
    
}
