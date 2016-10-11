//
//  LiveManager.swift
//  Live
//
//  Created by Denis Bohm on 10/10/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation
import ResearchKit

var sharedLiveManager = LiveManager()

class LiveManager {

    class var shared: LiveManager { get { return sharedLiveManager } }

    struct DailyStepCounts {
        let startDate: Date
        let stepCounts: [Int?]
    }

    let healthKitManager = HealthKitManager()
    let valueMessageManager = ValueMessageManager()
    let activityMessageManager = ActivityMessageManager()

    var dailyStepCounts = Observable<DailyStepCounts?>(value: nil)
    let orderedValues = Observable(value: ["Independence", "Politics", "Spirituality", "Humor", "Fame", "Power and Status", "Family and Friends", "Compassion and Kindness"])
    var valueMessage = Observable<Message?>(value: nil)
    var activityMessage = Observable<Message?>(value: nil)
    var notificationCount = 0

    init() {
    }

    var archivePath: URL {
        get {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentDirectory.appendingPathComponent("archive.plist")
        }
    }

    func archive(archiver: NSKeyedArchiver, key: String, property: Observable<Message?>) {
        if let message = property.value {
            let messageKey = MessageKey(group: message.group, identifier: message.identifier)
            Archiver.archive(archiver: archiver, prefix: "", key: key, property: messageKey)
        }
    }

    func unarchive(unarchiver: NSKeyedUnarchiver, key: String, messageManager: MessageManager, property: Observable<Message?>) {
        var messageKey = MessageKey(group: "", identifier: "")
        Archiver.unarchive(unarchiver: unarchiver, prefix: "", key: key, property: &messageKey)
        property.value = messageManager.find(group: messageKey.group, identifier: messageKey.identifier)
    }

    func archive() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        valueMessageManager.archive(archiver: archiver, prefix: "valueMessageManager.")
        activityMessageManager.archive(archiver: archiver, prefix: "activityMessageManager.")
        archive(archiver: archiver, key: "valueMessage", property: valueMessage)
        archive(archiver: archiver, key: "activityMessage", property: activityMessage)
        archiver.encode(orderedValues.value, forKey: "orderedValues")

        archiver.finishEncoding()
        do {
            try data.write(to: archivePath, options: Data.WritingOptions.atomic)
        } catch {
            NSLog("LiveManager.archive: error: \(error)")
        }
    }

    func unarchive() {
        let data: Data
        do {
            data = try Data(contentsOf: archivePath, options: [])
        } catch {
            NSLog("LiveManager.unarchive: error: \(error)")
            return
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)

        valueMessageManager.unarchive(unarchiver: unarchiver, prefix: "valueMessageManager.")
        activityMessageManager.unarchive(unarchiver: unarchiver, prefix: "activityMessageManager.")
        unarchive(unarchiver: unarchiver, key: "valueMessage", messageManager: valueMessageManager, property: valueMessage)
        unarchive(unarchiver: unarchiver, key: "activityMessage", messageManager: activityMessageManager, property: activityMessage)
        if let orderedValues = unarchiver.decodeObject(forKey: "orderedValues") as? [String] {
            self.orderedValues.value = orderedValues
        }

        orderedValues.subscribe(owner: self, observer: orderedValuesChanged)
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

    func queryHealthKit() {
        healthKitManager.queryMostRecentSamples()
    }

    func queryDailyStepCounts() {
        let _ = healthKitManager.queryDailyStepCounts(week: Week.last(), handler: dailyStepCounts)
    }

    func dailyStepCounts(startDate: Date, stepCounts: [Int?]) {
        dailyStepCounts.value = DailyStepCounts(startDate: startDate,  stepCounts: stepCounts)
    }

    func orderedValuesChanged() {
        valueMessageManager.filterGroup = orderedValues.value[0]
        nextValue()
    }

    func nextValue() {
        valueMessage.value = valueMessageManager.next()
    }

    func nextActivity() {
        activityMessage.value = activityMessageManager.next()
    }
    
    func scheduleNotification() {
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

    func cancelNotifications() {
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
