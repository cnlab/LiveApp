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

protocol LiveManagerDelegate {

    func liveManagerAffirm(_ liveManager: LiveManager, uuid: String, type: String, messageKey: Message.Key)

}

class LiveManager : NotificationManagerDelegate {

    class var shared: LiveManager { get { return sharedLiveManager } }

    struct DailyStepCounts {
        let startDate: Date
        let stepCounts: [Int?]
    }

    var delegate: LiveManagerDelegate?
    let notificationManager = createNotificationManager()
    let healthKitManager = HealthKitManager()
    let valueMessageManager = ValueMessageManager()
    let activityMessageManager = ActivityMessageManager()
    var messageManagers: [String: MessageManager] {
        get { return ["Value": valueMessageManager, "Activity": activityMessageManager] }
    }
    var dailyStepCounts = Observable<DailyStepCounts?>(value: nil)
    let orderedValues = Observable(value: ["Independence", "Politics", "Spirituality", "Humor", "Fame", "Power and Status", "Family and Friends", "Compassion and Kindness"])
    var valueMessage = Observable<Message?>(value: nil)
    var activityMessage = Observable<Message?>(value: nil)
    var schedule = Schedule(days: [])
    let horizon = 14
    var triggers: [String: DateComponents] = [
        "Value": DateComponents(hour: 9, minute: 0),
        "Activity": DateComponents(hour: 9, minute: 5)
        ]

    init() {
        notificationManager.delegate = self
    }

    var archivePath: URL {
        get {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentDirectory.appendingPathComponent("archive.plist")
        }
    }

    func archive(archiver: NSKeyedArchiver, key: String, property: Observable<Message?>) {
        if let message = property.value {
            Archiver.archive(archiver: archiver, prefix: "", key: key, property: message.key)
        }
    }

    func unarchive(unarchiver: NSKeyedUnarchiver, key: String, messageManager: MessageManager, property: Observable<Message?>) {
        var messageKey = Message.Key(group: "", identifier: "")
        Archiver.unarchive(unarchiver: unarchiver, prefix: "", key: key, property: &messageKey)
        property.value = messageManager.find(messageKey: messageKey)
    }

    func archiveSchedule(archiver: NSKeyedArchiver) {
        archiver.encode(schedule, forKey: "schedule")
    }

    func unarchiveSchedule(unarchiver: NSKeyedUnarchiver) {
        schedule = unarchiver.decodeObject(forKey: "schedule") as? Schedule ?? Schedule(days: [])
    }

    func archive() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiveSchedule(archiver: archiver)
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

    func unarchiveObjects(unarchiver: NSKeyedUnarchiver) {
        unarchiveSchedule(unarchiver: unarchiver)
        valueMessageManager.unarchive(unarchiver: unarchiver, prefix: "valueMessageManager.")
        activityMessageManager.unarchive(unarchiver: unarchiver, prefix: "activityMessageManager.")
        unarchive(unarchiver: unarchiver, key: "valueMessage", messageManager: valueMessageManager, property: valueMessage)
        unarchive(unarchiver: unarchiver, key: "activityMessage", messageManager: activityMessageManager, property: activityMessage)
        if let orderedValues = unarchiver.decodeObject(forKey: "orderedValues") as? [String] {
            self.orderedValues.value = orderedValues
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

        do {
            try ObjectiveCException.catch() {
                self.unarchiveObjects(unarchiver: unarchiver)
            }
        } catch {
            NSLog("unarchive error")
        }
    }

    func activate() {
        orderedValues.subscribe(owner: self, observer: orderedValuesChanged)

        extend()

        notificationManager.authorize() { (success: Bool, error: Error?) in self.notificationManagerUpdate() }
        authorizeHealthKit()
    }

    func affirm(uuid: String, type: String, messageKey: Message.Key, rank: Double) {
        for day in schedule.days {
            for note in day.notes {
                if note.uuid == uuid {
                    note.status = .rated(date: Date(), rank: 1.0)
                    if note.type == "Value" {
                        valueMessage.value = valueMessageManager.find(messageKey: note.messageKey)
                    } else
                        if note.type == "Activity" {
                            activityMessage.value = activityMessageManager.find(messageKey: note.messageKey)
                    }
                    break
                }
            }
        }
        if !schedule.isPending {
            notificationManager.nothingPending()
        }
        notificationManager.getOutstanding()
    }

    func notificationManager(_ notificationManager: NotificationManager, action: String, uuid: String, type: String, messageKey: Message.Key) {
        if action == "affirm" {
            affirm(uuid: uuid, type: type, messageKey: messageKey, rank: 1.0)
        } else {
            delegate?.liveManagerAffirm(self, uuid: uuid, type: type, messageKey: messageKey)
        }
    }

    func notificationManagerUpdate() {
        if !notificationManager.authorized {
            return
        }

        notificationManager.cancel()

        for day in schedule.days {
            for note in day.notes {
                if
                    case .pending = note.status,
                    let messageManager = messageManagers[note.type],
                    let message = messageManager.find(messageKey: note.messageKey),
                    let dateComponents = triggers[note.type]
                {
                    notificationManager.request(date: day.date, components: dateComponents, uuid: note.uuid, type: note.type, message: message)
                }
            }
        }
    }

    func setScheduleDays(days: [Schedule.Day]) {
        schedule = Schedule(days: days)
        notificationManagerUpdate()
    }

    func notificationManager(_ notificationManager: NotificationManager, outstanding: [NoteKey]) {
        var uuids = Set<String>()
        for noteKey in outstanding {
            uuids.insert(noteKey.uuid)
        }

        let date = Date()
        for day in schedule.days {
            if day.date < date {
                for note in day.notes {
                    if case .pending = note.status {
                        if !uuids.contains(note.uuid) {
                            note.status = .closed
                        }
                    }
                }
            }
        }
    }

    func nextNotes() -> [Note] {
        var notes: [Note] = []
        for (type, messageManager) in messageManagers {
            notes.append(Note(uuid: UUID().uuidString, type: type, messageKey: messageManager.next(), status: .pending))
        }
        return notes
    }

    func reschedule() {
        // append days up to the horizon
        var days: [Schedule.Day] = []
        let now = Date()
        let valueDateComponents = triggers["Value"]!
        var date = Time.next(date: now, at: valueDateComponents)
        for _ in 0 ..< horizon {
            let notes = nextNotes()
            days.append(Schedule.Day(date: date, notes: notes))
            date = Time.next(date: date)
        }

        setScheduleDays(days: days)
    }

    // extend the schedule so it covers up to the horizon (2 weeks)
    func extend() {
        guard let lastDay = schedule.days.last else {
            reschedule()
            return
        }

        var days: [Schedule.Day] = []
        let calendar = Calendar.current
        let now = Date()
        let valueDateComponents = triggers["Value"]!
        let startDate = Time.next(date: now, at: valueDateComponents)
        let endDate = calendar.date(byAdding: .day, value: horizon, to: startDate)!

        // only keep days in the future
        for day in schedule.days {
            if day.date > now {
                days.append(day)
            }
        }

        // append days up to the horizon
        let nextDate = Time.next(date: lastDay.date, at: valueDateComponents)
        var date = nextDate > startDate ? nextDate : startDate
        while date < endDate {
            let notes = nextNotes()
            days.append(Schedule.Day(date: date, notes: notes))
            date = Time.next(date: date)
        }

        setScheduleDays(days: days)
    }

    // advance messages by 1 day - for testing -denis
    func advance() {
        var days: [Schedule.Day] = []
        for index in 0 ..< schedule.days.count - 1 {
            let a = schedule.days[index]
            let b = schedule.days[index + 1]
            days.append(Schedule.Day(date: a.date, notes: b.notes))
        }
        if let last = schedule.days.last {
            let notes = nextNotes()
            days.append(Schedule.Day(date: last.date, notes: notes))
        }

        setScheduleDays(days: days)
    }

    func orderedValuesChanged() {
        valueMessageManager.filterGroup = orderedValues.value[0]
        reschedule()
    }

    func refresh() {
        extend()

        if healthKitManager.authorized {
            queryDailyStepCounts()
        }
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
        let _ = healthKitManager.queryDailyStepCounts(week: Time.lastWeek(), handler: dailyStepCounts)
    }

    func dailyStepCounts(startDate: Date, stepCounts: [Int?]) {
        dailyStepCounts.value = DailyStepCounts(startDate: startDate,  stepCounts: stepCounts)
    }

}
