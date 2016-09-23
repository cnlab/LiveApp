//
//  FirstViewController.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import ResearchKit
import UIKit

extension FirstViewController : ORKTaskViewControllerDelegate {

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        //Handle results with taskViewController.result
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
}

class FirstViewController: UIViewController {

    let healthKitManager = HealthKitManager()
    var notificationCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func consentTapped(_ sender: AnyObject) {
        let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    @IBAction func surveyTapped(_ sender: AnyObject) {
        let taskViewController = ORKTaskViewController(task: SurveyTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    @IBAction func authorizeHealthKitTapped(_ sender: AnyObject) {
        do {
            try healthKitManager.authorizeHealthKit { (authorized,  error) -> Void in
                if authorized {
                    print("HealthKit authorization received.")
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

    @IBAction func queryTapped(_ sender: AnyObject) {
        healthKitManager.queryMostRecentSamples()
        healthKitManager.queryLastWeekOfDailyStepCounts()
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
