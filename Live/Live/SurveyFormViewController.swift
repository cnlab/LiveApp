//
//  SurveyFormViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyFormViewController: TrackerViewController {

    var submitCallback: (([String : Any]) -> Void)? = nil

    @IBOutlet var questionOneSegmentedControl: UISegmentedControl?
    @IBOutlet var questionTwoSegmentedControl: UISegmentedControl?
    @IBOutlet var questionThreeSegmentedControl: UISegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func answer(segmentedControl: UISegmentedControl?) -> String {
        if let index = segmentedControl?.selectedSegmentIndex {
            if let title = segmentedControl?.titleForSegment(at: index) {
                return title
            }
        }
        return ""
    }

    @IBAction func submitSurveyAction() {
        if let submitCallback = submitCallback {
            var answers: [String : Any] = [:]
            answers["Q1"] = answer(segmentedControl: questionOneSegmentedControl)
            answers["Q2"] = answer(segmentedControl: questionTwoSegmentedControl)
            answers["Q3"] = answer(segmentedControl: questionThreeSegmentedControl)
            Tracker.sharedInstance().record(category: "Survey", name: "Submit")
            submitCallback(answers)
        }
    }

}
