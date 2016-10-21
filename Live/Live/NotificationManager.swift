//
//  NotificationManager.swift
//  Live
//
//  Created by Denis Bohm on 10/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

struct NoteKey {
    let date: Date
    let uuid: String
    let type: String
    let messageKey: Message.Key
}

protocol NotificationManagerDelegate {

    func notificationManager(_ notificationManager: NotificationManager, action: String, uuid: String, type: String, messageKey: Message.Key)
    func notificationManager(_ notificationManager: NotificationManager, outstanding: [NoteKey])
    
}

protocol NotificationManager {

    var delegate: NotificationManagerDelegate? { get set }
    var authorized: Bool { get }
    func authorize(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void))
    func cancel()
    func request(date: Date, components: DateComponents, uuid: String, type: String, message: Message)
    func getOutstanding()
    func nothingPending()

}

func createNotificationManager() -> NotificationManager {
    if #available(iOS 10.0, *) {
        return NotificationManager10()
    } else {
        return NotificationManager9()
    }
}

class NotificationManager9 : NotificationManager {

    var delegate: NotificationManagerDelegate? = nil
    var authorized: Bool = false

    func authorize(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }

    func getDelivered() {
    }
    
    func cancel() {
        let application = UIApplication.shared
        if let notifications = application.scheduledLocalNotifications {
            for notification in notifications {
                application.cancelLocalNotification(notification)
            }
        }

        application.applicationIconBadgeNumber = 0
    }
    
    func request(date: Date, components: DateComponents, uuid: String, type: String, message: Message) {
        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSinceNow: 5.0)
        notification.alertAction = "Affirm"
        notification.alertBody = message.format()
        notification.alertTitle = type
        notification.applicationIconBadgeNumber = 1
        let application = UIApplication.shared
        application.scheduleLocalNotification(notification)
    }

    func getOutstanding() {
    }
    
    func nothingPending() {
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
    }

}

@available(iOS 10.0, *)
class NotificationManager10 : NSObject, UNUserNotificationCenterDelegate, NotificationManager {

    var delegate: NotificationManagerDelegate? = nil
    var authorized: Bool = false

    func authorize(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(success, error) in
            self.authorized(success: success, error: error)
        }
    }

    func authorized(success: Bool, error: Error?) {
        authorized = success
        
        if !success {
            print("Notification access denied.")
            return
        }

        let action = UNNotificationAction(identifier: "affirm", title: "Affirm", options: [.foreground])
        let category = UNNotificationCategory(identifier: "Affirmation", actions: [action], intentIdentifiers: [], options: [])
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.delegate = self
        userNotificationCenter.setNotificationCategories([category])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        NSLog("alert")
        completionHandler(UNNotificationPresentationOptions.alert)
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        if
            let uuid = userInfo["uuid"] as? String,
            let type = userInfo["type"] as? String,
            let group = userInfo["group"] as? String,
            let identifier = userInfo["identifier"] as? String
        {
            let action = response.actionIdentifier
            NSLog("\(action) \(uuid) \(type) \(group) \(identifier)")
            if let delegate = delegate {
                delegate.notificationManager(self, action: action, uuid: uuid, type: type, messageKey: Message.Key(group: group, identifier: identifier))
            }
            nothingPending()
        }
        completionHandler()
    }

    public func nothingPending() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
    }

    func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func request(date: Date, components: DateComponents, uuid: String, type: String, message: Message) {
        let trigger: UNNotificationTrigger?
        var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        triggerComponents.hour = components.hour
        triggerComponents.minute = components.minute
        let date = Calendar.current.date(from: triggerComponents)!
        if date > Date(timeIntervalSinceNow: 5.0) {
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        } else {
            trigger = nil
        }

        let content = UNMutableNotificationContent()
        content.title = type
        content.body = message.format()
        content.badge = NSNumber(value: 1)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "Affirmation"
        content.userInfo = [
            "date": Calendar.current.date(from: triggerComponents)!,
            "uuid": uuid,
            "type": type,
            "group": message.key.group,
            "identifier": message.key.identifier
        ]

        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                NSLog("add notification error: \(trigger) \(uuid) \(error)")
            }
        }
    }

    func deliveredAndPending(delivered: [UNNotification], pending: [UNNotificationRequest]) {
        // third union the delivered and pending
        var outstanding: [NoteKey] = []
        for request in pending {
            let userInfo = request.content.userInfo
            if
                let date = userInfo["date"] as? Date,
                let uuid = userInfo["uuid"] as? String,
                let type = userInfo["type"] as? String,
                let group = userInfo["group"] as? String,
                let identifier = userInfo["identifier"] as? String
            {
                outstanding.append(NoteKey(date: date, uuid: uuid, type: type, messageKey: Message.Key(group: group, identifier: identifier)))
            }
        }
        for notification in delivered {
            let userInfo = notification.request.content.userInfo
            if
                let date = userInfo["date"] as? Date,
                let uuid = userInfo["uuid"] as? String,
                let type = userInfo["type"] as? String,
                let group = userInfo["group"] as? String,
                let identifier = userInfo["identifier"] as? String
            {
                outstanding.append(NoteKey(date: date, uuid: uuid, type: type, messageKey: Message.Key(group: group, identifier: identifier)))
            }
        }
        if let delegate = delegate {
            delegate.notificationManager(self, outstanding: outstanding)
        }
    }

    func deliveredNotifications(notifications: [UNNotification]) {
        // second get the pending notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests() { (requests: [UNNotificationRequest]) in self.deliveredAndPending(delivered: notifications, pending: requests) }
    }

    public func getOutstanding() {
        // first get the delivered and not acted on yet notifications
        UNUserNotificationCenter.current().getDeliveredNotifications() { (notifications: [UNNotification]) in self.deliveredNotifications(notifications: notifications) }
    }
    
}
