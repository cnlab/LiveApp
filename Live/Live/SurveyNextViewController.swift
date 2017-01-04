//
//  SurveyNextViewController.swift
//  Live
//
//  Created by Denis Bohm on 1/2/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import UIKit

class SurveyNextViewController: UIViewController {

    @IBOutlet var whenLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        update()
    }

    func update() {
        let surveyManager = LiveManager.shared.surveyManager
        let days = Int(ceil(surveyManager.scheduledDate.timeIntervalSince(Date()) / (24 * 60 * 60)))
        whenLabel?.text = "Your next survey is due in \(days) " + (days > 1 ? "days" : "day") + "."
    }

}
