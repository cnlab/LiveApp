//
//  HomeViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import ResearchKit
import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var motivationalTextView: UITextView?
    @IBOutlet var stepsView: StepsView?
    @IBOutlet var valueTextView: UITextView?
    @IBOutlet var activityTextView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.dailyStepCounts.subscribe(owner: self, observer: dailyStepCountsChanged)
        liveManager.valueMessage.subscribe(owner: self, observer: valueChanged)
        liveManager.activityMessage.subscribe(owner: self, observer: activityChanged)

        dailyStepCountsChanged()
        valueChanged()
        activityChanged()
    }

    func dailyStepCountsChanged() {
        if let stepsView = stepsView {
            let liveManager = LiveManager.shared
            if let dailyStepCounts = liveManager.dailyStepCounts.value {
                stepsView.update(startDate: dailyStepCounts.startDate, stepCounts: dailyStepCounts.stepCounts)
            } else {
                stepsView.update(startDate: Date(), stepCounts: [nil, nil, nil, nil, nil, nil, nil] as [Int?])
            }
        }
    }

    func showMessage(view: UITextView?, message: Message?, prefix: String? = nil) {
        if let view = view {
            var text = ""
            if let message = message {
                text = message.format()
                if let prefix = prefix {
                    text = prefix + " " + text + "."
                }
            }
            view.text = text
        }
    }

    func valueChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: valueTextView, message: liveManager.valueMessage.value, prefix: "Think about")
    }

    func activityChanged() {
        let liveManager = LiveManager.shared
        showMessage(view: activityTextView, message: liveManager.activityMessage.value)
    }

    @IBAction func respondToValueTouched(_ sender: AnyObject) {
        let liveManager = LiveManager.shared
        liveManager.nextValue()
    }

    @IBAction func respondToActivityTouched(_ sender: AnyObject) {
        let liveManager = LiveManager.shared
        liveManager.nextActivity()
    }
    
    @IBAction func scheduleNotificationTapped(_ sender: AnyObject) {
        let liveManager = LiveManager.shared
        liveManager.scheduleNotification()
    }

    @IBAction func cancelNotificationsTapped(_ sender: AnyObject) {
        let liveManager = LiveManager.shared
        liveManager.cancelNotifications()
    }

}
