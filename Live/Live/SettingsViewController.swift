//
//  SettingsViewController.swift
//  Live
//
//  Created by Denis Bohm on 10/21/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit
import LiveViews

class SettingsViewController: TrackerViewController {

    @IBOutlet var slotSegmentedControl: UISegmentedControl?
    @IBOutlet var timePicker: UIDatePicker?
    @IBOutlet var showSettingsButton: UIButton?
    @IBOutlet var timeLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        let liveManager = LiveManager.shared
        liveManager.triggers.subscribe(owner: self, observer: triggersChanged)
        triggersChanged()

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
    
    func triggerDateToday(trigger: DateComponents) -> Date {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = trigger.hour
        dateComponents.minute = trigger.minute
        let date = Calendar.current.date(from: dateComponents)!
        return date
    }
    
    func triggersChanged() {
        let liveManager = LiveManager.shared
        let triggers = liveManager.triggers.value
        let slotCount = triggers.count
        let currentSlotCount = slotSegmentedControl?.numberOfSegments ?? 0
        if slotCount != currentSlotCount {
            slotSegmentedControl?.removeAllSegments()
            for _ in 0 ..< slotCount {
                slotSegmentedControl?.insertSegment(withTitle: "time", at: 0, animated: false)
            }
            if slotCount > 0 {
                slotSegmentedControl?.selectedSegmentIndex = 0
            }
        }
        slotSegmentedControl?.isHidden = slotCount <= 1

        if slotCount == 0 {
            return
        }
        
        let slotIndex = slotSegmentedControl?.selectedSegmentIndex ?? 0
        let trigger = triggers[slotIndex]
        let date = triggerDateToday(trigger: trigger)
        if timePicker?.date != date {
            timePicker?.date = date
        }
        
        let formatter = NumberFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        formatter.numberStyle = .ordinal
        for i in 0 ..< (slotSegmentedControl?.numberOfSegments ?? 0) {
            let trigger = triggers[i]
            let date = triggerDateToday(trigger: trigger)
            let name = formatter.string(from: NSNumber(value: i + 1)) ?? "nth"
            let time = dateFormatter.string(from: date)
            slotSegmentedControl?.setTitle("\(name) time\n\(time)", forSegmentAt: i)
        }
        if let multilineSegmentedControl = slotSegmentedControl as? MultilineSegmentedControl {
            multilineSegmentedControl.setDefaults()
        }
    }
    
    @IBAction func segmentChanged() {
        let liveManager = LiveManager.shared
        let triggers = liveManager.triggers.value
        let slotIndex = slotSegmentedControl?.selectedSegmentIndex ?? 0
        let trigger = triggers[slotIndex]
        let date = triggerDateToday(trigger: trigger)
        if timePicker?.date != date {
            timePicker?.date = date
        }
    }

    func areInIncreasingOrder(_ a: DateComponents, _ b: DateComponents) -> Bool {
        if (a.hour ?? 0) < (b.hour ?? 0) {
            return true
        }
        if (a.hour ?? 0) > (b.hour ?? 0) {
            return false
        }
        if (a.minute ?? 0) < (b.minute ?? 0) {
            return true
        }
        if (a.minute ?? 0) > (b.minute ?? 0) {
            return false
        }
        return false
    }
    
    func inIncreasingOrder(triggers: [DateComponents]) -> [DateComponents] {
        return triggers.sorted { areInIncreasingOrder($0, $1) }
    }
    
    func lessThanOrEqualTo(_ a: DateComponents, _ b: DateComponents) -> Bool {
        if (a.hour ?? 0) < (b.hour ?? 0) {
            return true
        }
        if (a.hour ?? 0) > (b.hour ?? 0) {
            return false
        }
        if (a.minute ?? 0) < (b.minute ?? 0) {
            return true
        }
        if (a.minute ?? 0) > (b.minute ?? 0) {
            return false
        }
        return true
    }
    
    func add(trigger: DateComponents, minutes: Int) -> DateComponents {
        var hour = trigger.hour ?? 0
        var minute = trigger.minute ?? 0
        minute += minutes
        if minute >= 60 {
            hour += minute / 60
            minute = minute % 60
        }
        if hour > 23 {
            hour = 23
            minute = 55
        }
        return DateComponents(hour: hour, minute: minute)
    }
    
    func subtract(trigger: DateComponents, minutes: Int) -> DateComponents {
        var hour = trigger.hour ?? 0
        var minute = trigger.minute ?? 0
        minute -= minutes
        if minute < 0 {
            hour += minute / 60
            minute = 60 - (-minute % 60)
        }
        if hour < 0 {
            hour = 0
            minute = 0
        }
        return DateComponents(hour: hour, minute: minute)
    }
    
    func spread(triggers: [DateComponents]) -> [DateComponents] {
        var triggers = triggers
        var lastTrigger = triggers[0]
        for i in 1 ..< triggers.count {
            let trigger = triggers[i]
            if lessThanOrEqualTo(trigger, lastTrigger) {
                triggers[i] = add(trigger: lastTrigger, minutes: 5)
            }
            lastTrigger = triggers[i]
        }
        for i in (0 ..< triggers.count - 1).reversed() {
            let trigger = triggers[i]
            if lessThanOrEqualTo(lastTrigger, trigger) {
                triggers[i] = subtract(trigger: lastTrigger, minutes: 5)
            }
            lastTrigger = triggers[i]
        }
        return triggers
    }
    
    @IBAction func timeChanged() {
        guard let timePicker = timePicker else {
            return
        }
        
        let trigger = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        do {
            let liveManager = LiveManager.shared
            var triggers = liveManager.triggers.value
            let slotIndex = slotSegmentedControl?.selectedSegmentIndex ?? 0
            triggers[slotIndex] = trigger
            triggers = inIncreasingOrder(triggers: triggers)
            let index = triggers.index(of: trigger)!
            triggers = spread(triggers: triggers)
            
            liveManager.triggers.value = triggers
            if index != slotIndex {
                slotSegmentedControl?.selectedSegmentIndex = index
                segmentChanged()
            }
        }
        
        if let label = timeLabel {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let time = dateFormatter.string(from: triggerDateToday(trigger: trigger))
            Tracker.sharedInstance().record(category: "Settings", name: "Time", value: time)
            label.text = "You will be reminded at \(time)."
            UIView.transition(with: label, duration: 0.3, options: [.transitionCrossDissolve], animations: { label.textColor = .black }, completion: { animationFinished in
                UIView.transition(with: label, duration: 1.0, options: [.transitionCrossDissolve], animations: { label.textColor = .lightGray }, completion: nil)
            } )
        }
    }

}
