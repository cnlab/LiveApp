//
//  SettingsViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/21/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

class SettingsViewController: TrackerViewController {

    @IBOutlet var timePicker: UIDatePicker?
    @IBOutlet var showSettingsButton: UIButton?
    @IBOutlet var timeLabel: UILabel?

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
        guard let showSettingsButton = showSettingsButton else {
            return
        }
        let hide = LiveManager.shared.notificationManager.authorized.value
        let hidden = showSettingsButton.isHidden
        if hide != hidden {
            showSettingsButton.isHidden = hide
            view.setNeedsLayout()
        }
    }

    func queryAuthorization() {
        let notificationManager = LiveManager.shared.notificationManager
        notificationManager.queryAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        queryAuthorization()
    }
    
    @objc func willEnterForeground() {
        queryAuthorization()
    }

    @IBAction func showSettings() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
    }

    func triggerDateToday() -> Date {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let liveManager = LiveManager.shared
        let trigger = liveManager.trigger.value
        dateComponents.hour = trigger.hour
        dateComponents.minute = trigger.minute
        let date = Calendar.current.date(from: dateComponents)!
        return date
    }
    
    func triggerChanged() {
        let date = triggerDateToday()
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
        
        if let label = timeLabel {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let time = dateFormatter.string(from: triggerDateToday())
            Tracker.sharedInstance().event(category: "Settings", name: "Time", value: time)
            label.text = "You will be reminded at \(time)."
            UIView.transition(with: label, duration: 0.3, options: [.transitionCrossDissolve], animations: { label.textColor = .black }, completion: { animationFinished in
                UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve], animations: { label.textColor = .lightGray }, completion: nil)
            } )
        }
    }

}
