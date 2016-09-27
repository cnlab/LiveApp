//
//  FirstViewController.swift
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

    let healthKitManager = HealthKitManager()
    let valueMessageManager = ValueMessageManager()
    let activityMessageManager = ActivityMessageManager()
    var notificationCount = 0
    var weeklyStartDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        nextValue()
        nextActivity()

        weeklyStartDate = Date()
        stepsView?.update(startDate: weeklyStartDate, stepCounts: [nil, nil, nil, nil, nil, nil, nil])
        authorizeHealthKit()
    }

    func authorizeHealthKit() {
        do {
            try healthKitManager.authorizeHealthKit { (authorized,  error) -> Void in
                if authorized {
                    DispatchQueue.main.async {
                        self.queryDailyStepCounts()
                    }
                } else {
                    print("HealthKit authorization denied!")
                    if error != nil {
                        print("\(error)")
                    }
                }
            }
        } catch {
            print("HealthKit not available")
        }
    }

    func queryDailyStepCounts() {
        weeklyStartDate = healthKitManager.queryLastWeekOfDailyStepCounts(handler: dailyStepCounts)
    }

    func dailyStepCounts(startDate: Date, stepCounts: [Int?]) {
        stepsView?.update(startDate: startDate, stepCounts: stepCounts)
    }

    func nextValue() {
        valueTextView?.text = "Think about " + MessageManager.format(message: valueMessageManager.next()) + "."
    }

    func nextActivity() {
        activityTextView?.text = MessageManager.format(message: activityMessageManager.next())
    }

    @IBAction func respondToValueTouched(_ sender: AnyObject) {
        nextValue()
    }

    @IBAction func respondToActivityTouched(_ sender: AnyObject) {
        nextActivity()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func queryHealthKit() {
        healthKitManager.queryMostRecentSamples()
    }

    @IBAction func scheduleNotificationTapped(_ sender: AnyObject) {
        notificationCount += 1

        let application = UIApplication.shared
        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSinceNow: 5.0)
        notification.alertAction = "Act Now"
        notification.alertBody = "Do something cool \(Date())."
        notification.alertTitle = "Just Do It."
        notification.applicationIconBadgeNumber = notificationCount
        application.scheduleLocalNotification(notification)
        application.applicationIconBadgeNumber = notificationCount
    }

    @IBAction func cancelNotificationsTapped(_ sender: AnyObject) {
        let application = UIApplication.shared
        if let notifications = application.scheduledLocalNotifications {
            for notification in notifications {
                application.cancelLocalNotification(notification)
            }
        }

        notificationCount = 0
        application.applicationIconBadgeNumber = 0
    }

}
