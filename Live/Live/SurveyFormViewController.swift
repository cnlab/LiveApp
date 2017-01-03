//
//  SurveyFormViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyFormViewController: UIViewController {

    var submitCallback: ((Void) -> Void)? = nil

    @IBOutlet var questionOneSegmentedControl: UISegmentedControl?
    @IBOutlet var questionTwoSegmentedControl: UISegmentedControl?
    @IBOutlet var questionThreeSegmentedControl: UISegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func submitSurveyAction() {
        if let submitCallback = submitCallback {
            submitCallback()
        }
    }

}
