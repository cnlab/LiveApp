//
//  SettingsViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/21/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var timePicker: UIDatePicker?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.trigger.subscribe(owner: self, observer: triggerChanged)
        triggerChanged()
    }

    open override func viewDidLayoutSubviews() {
        Layout.vertical(viewController: self)
    }

    func triggerChanged() {
        let liveManager = LiveManager.shared
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let trigger = liveManager.trigger.value
        dateComponents.hour = trigger.hour
        dateComponents.minute = trigger.minute
        let date = Calendar.current.date(from: dateComponents)!
        if timePicker?.date != date {
            timePicker?.date = date
        }
    }

    @IBAction func timeChanged() {
        guard let timePicker = timePicker else {
            return
        }

        let liveManager = LiveManager.shared
        liveManager.trigger.value = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
    }

}
