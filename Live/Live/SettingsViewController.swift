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
    @IBOutlet var showSettingsButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.trigger.subscribe(owner: self, observer: triggerChanged)
        triggerChanged()

        let notificationManager = liveManager.notificationManager
        notificationManager.authorized.subscribe(owner: self, observer: notificationManagerAuthorizationChanged)
        notificationManagerAuthorizationChanged()

        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    func notificationManagerAuthorizationChanged() {
        showSettingsButton?.isHidden = LiveManager.shared.notificationManager.authorized.value
    }

    func queryAuthorization() {
        let notificationManager = LiveManager.shared.notificationManager
        notificationManager.queryAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        queryAuthorization()
    }

    func willEnterForeground() {
        queryAuthorization()
    }

    @IBAction func showSettings() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
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
