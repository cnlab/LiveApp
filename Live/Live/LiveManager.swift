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

    func liveManagerAffirm(_ liveManager: LiveManager, uuid: String, type: String, messageKey: Message.Key, rank: Double)

}

class LiveManager: NotificationManagerDelegate {

    class var shared: LiveManager { get { return sharedLiveManager } }

    struct DailyStepCounts {
        let startDate: Date
        let stepCounts: [Int?]
    }

    var installationDate: Date? = nil
    var installationUUID: String? = nil
    var delegate: LiveManagerDelegate?
    let notificationManager = createNotificationManager()
    var didAuthorizeNotificationManager = false {
        willSet(newValue) {
            if newValue != didAuthorizeNotificationManager {
                dirty = true
            }
        }
    }
    let healthKitManager = HealthKitManager()
    var didAuthorizeHealthKit = false {
        willSet(newValue) {
            if newValue != didAuthorizeHealthKit {
                dirty = true
            }
        }
    }
    let valueMessageManager = ValueMessageManager()
    var didShowGetStarted = false {
        willSet(newValue) {
            if newValue != didShowGetStarted {
                dirty = true
            }
        }
    }
    var didShowShareReminder = false {
        willSet(newValue) {
            if newValue != didShowShareReminder {
                dirty = true
            }
        }
    }
    let activityMessageManager = ActivityMessageManager()
    var messageManagers: [String: MessageManager] {
        get { return ["Value": valueMessageManager, "Activity": activityMessageManager] }
    }
    var personalInformation = Observable<PersonalInformation>(value: PersonalInformation())
    var shareDataWithResearchers: Bool = false {
        willSet(newValue) {
            if newValue != shareDataWithResearchers {
                dirty = true
            }
        }
    }
    let surveyManager = SurveyManager()
    var dailyStepCounts = Observable<DailyStepCounts?>(value: nil)
    let orderedValues = Observable(value: ["Independence", "Politics", "Spirituality", "Humor", "Fame", "Power and Status", "Family and Friends", "Compassion and Kindness"])
    var valueNote = Observable<Note?>(value: nil)
    var activityNote = Observable<Note?>(value: nil)
    var schedule = Schedule(days: [])
    let horizon = 14
    var trigger = Observable<DateComponents>(value: DateComponents(hour: 9, minute: 0))
    var triggerOffsets: [String: TimeInterval] = ["Activity": 0, "Value": 10]
    var modificationDate = Date()
    var dirty = false {
        didSet {
            if dirty {
                modificationDate = Date()
                DispatchQueue.main.async {
                    self.checkDirty()
                }
            }
        }
    }

    init() {
        orderedValues.subscribe(owner: self, observer: orderedValuesChanged)
        trigger.subscribe(owner: self, observer: triggerChanged)
        personalInformation.subscribe(owner: self, observer: personalInformationChanged)

        notificationManager.delegate = self
        notificationManager.authorized.subscribe(owner: self, observer: notificationManagerAuthorizationChanged)

        healthKitManager.bodyMass.subscribe(owner: self, observer: bodyMassChanged)
        healthKitManager.height.subscribe(owner: self, observer: heightChanged)
    }

    func personalInformationChanged() {
        dirty = true
    }

    func bodyMassChanged() {
        if let sample = healthKitManager.bodyMass.value {
            if personalInformation.value.weight == nil {
                let weight = Int(sample.quantity.doubleValue(for: HKUnit.pound()))
                personalInformation.value = personalInformation.value.bySetting(weight: weight)
            }
        }
    }

    func heightChanged() {
        if let sample = healthKitManager.height.value {
            if personalInformation.value.height == nil {
                let height = Int(sample.quantity.doubleValue(for: HKUnit.inch()))
                personalInformation.value = personalInformation.value.bySetting(height: height)
            }
        }
    }

    var archivePath: URL {
        get {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentDirectory.appendingPathComponent("archive.json")
        }
    }

    static func json(dateComponents: DateComponents) -> [String: Any] {
        return [
            "hour": dateComponents.hour ?? 0,
            "minute": dateComponents.minute ?? 0,
        ]
    }

    static func jsonDefaultDateComponents(json: [String: Any], key: String, fallback: DateComponents) throws -> DateComponents {
        if json[key] == nil {
            return fallback
        }
        guard let jsonDictionary = json[key] as? [String: Any] else {
            throw JSON.SerializationError.invalid(key)
        }
        let hour = (jsonDictionary["hour"] as? Int) ?? 0
        let minute = (jsonDictionary["minute"] as? Int) ?? 0
        return DateComponents(hour: hour, minute: minute)
    }

    func archive() {
        let json: [String: Any] = [
            "installationDate": JSON.json(date: installationDate ?? Date()),
            "installationUUID": JSON.json(string: installationUUID ?? ""),
            "modificationDate": JSON.json(date: modificationDate),
            "trigger": LiveManager.json(dateComponents: trigger.value),
            "schedule": JSON.json(object: schedule),
            "valueMessageManager": JSON.json(object: valueMessageManager.state),
            "activityMessageManager": JSON.json(object: activityMessageManager.state),
            "orderedValues": JSON.json(array: orderedValues.value),
            "didAuthorizeNotificationManager": JSON.json(bool: didAuthorizeNotificationManager),
            "didAuthorizeHealthKit": JSON.json(bool: didAuthorizeHealthKit),
            "didShowGetStarted": JSON.json(bool: didShowGetStarted),
            "didShowShareReminder": JSON.json(bool: didShowShareReminder),
            "surveyManager": JSON.json(object: surveyManager.state),
            "personalInformation": JSON.json(object: personalInformation.value),
            "shareDataWithResearchers": JSON.json(bool: shareDataWithResearchers),
        ]
        do {
            let data = try JSON.json(any: json)
            try data.write(to: archivePath, options: Data.WritingOptions.atomic)
            NSLog("LiveManager.archive: success")
        } catch {
            NSLog("LiveManager.archive: error: \(error)")
        }
    }

    func unarchive() -> Bool {
        do {
            let data = try Data(contentsOf: archivePath, options: [])
            guard let json = try JSON.json(data: data) as? [String: Any] else {
                throw JSON.SerializationError.invalid("root")
            }

            let installationDate = try JSON.jsonOptionalDate(json: json, key: "installationDate")
            let installationUUID = try JSON.jsonOptionalString(json: json, key: "installationUUID")
            let modificationDate = try JSON.jsonDefaultDate(json: json, key: "modificationDate", fallback: self.modificationDate)
            let trigger = try LiveManager.jsonDefaultDateComponents(json: json, key: "trigger", fallback: self.trigger.value)
            let schedule: Schedule = try JSON.jsonObject(json: json, key: "schedule")
            let valueMessageManager: ValueMessageManager.State = try JSON.jsonObject(json: json, key: "valueMessageManager")
            let activityMessageManager: ActivityMessageManager.State = try JSON.jsonObject(json: json, key: "activityMessageManager")
            let orderedValues: [String] = try JSON.jsonArray(json: json, key: "orderedValues")
            let didAuthorizeNotificationManager: Bool = try JSON.jsonDefaultBool(json: json, key: "didAuthorizeNotificationManager")
            let didAuthorizeHealthKit: Bool = try JSON.jsonDefaultBool(json: json, key: "didAuthorizeHealthKit")
            let didShowGetStarted: Bool = try JSON.jsonDefaultBool(json: json, key: "didShowGetStarted")
            let didShowShareReminder: Bool = try JSON.jsonDefaultBool(json: json, key: "didShowShareReminder")
            let surveyManager: SurveyManager.State = try JSON.jsonDefaultObject(json: json, key: "surveyManager", fallback: self.surveyManager.state)
            let personalInformation: PersonalInformation = try JSON.jsonDefaultObject(json: json, key: "personalInformation", fallback: self.personalInformation.value)
            let shareDataWithResearchers: Bool = try JSON.jsonDefaultBool(json: json, key: "shareDataWithResearchers")

            self.installationDate = installationDate
            self.installationUUID = installationUUID
            self.modificationDate = modificationDate
            self.trigger.value = trigger
            self.schedule = schedule
            self.valueMessageManager.state = valueMessageManager
            self.activityMessageManager.state = activityMessageManager
            self.orderedValues.value = orderedValues
            self.didAuthorizeNotificationManager = didAuthorizeNotificationManager
            self.didAuthorizeHealthKit = didAuthorizeHealthKit
            self.didShowGetStarted = didShowGetStarted
            self.didShowShareReminder = didShowShareReminder
            self.surveyManager.state = surveyManager
            self.personalInformation.value = personalInformation
            self.shareDataWithResearchers = shareDataWithResearchers

            dirty = false
        } catch {
            NSLog("LiveManager.unarchive: error: \(error)")
            return false
        }
        return true
    }

    func checkDirty() {
        if dirty {
            archive()
        }
    }

    func activate() {
        if installationUUID == nil {
            installationDate = Date()
            installationUUID = UUID().uuidString
            dirty = true
        }

        extend()

        if didAuthorizeNotificationManager {
            authorizeNotificationManager()
        }
        if didAuthorizeHealthKit {
            authorizeHealthKit()
        }
    }

    func authorizeNotificationManager() {
        didAuthorizeNotificationManager = true

        notificationManager.authorize()
    }

    func affirm(uuid: String, type: String, messageKey: Message.Key, rank: Double) {
        var found = false
        for day in schedule.days {
            for note in day.notes {
                if note.uuid == uuid {
                    note.status = .rated(date: Date(), rank: rank)
                    found = true
                    break
                }
            }
        }
        if !found {
            NSLog("could not find uuid \(uuid)")
        }
        valueNote.value = valueNote.value
        activityNote.value = activityNote.value
        dirty = true
        if !schedule.isPending {
            notificationManager.nothingPending()
        }
        notificationManager.getOutstanding()
    }

    func notificationManager(_ notificationManager: NotificationManager, action: String, uuid: String, type: String, messageKey: Message.Key) {
        if action == "affirm" {
            affirm(uuid: uuid, type: type, messageKey: messageKey, rank: 1.0)
        } else {
            delegate?.liveManagerAffirm(self, uuid: uuid, type: type, messageKey: messageKey, rank: 0.5)
        }
    }

    func showCurrentNotifications() {
        var valueNote: Note? = nil
        var activityNote: Note? = nil
        for day in schedule.days {
            for note in day.notes {
                if !note.isPending {
                    if note.type == "Value" {
                        valueNote = note
                    } else
                    if note.type == "Activity" {
                        activityNote = note
                    }
                }
            }
        }
        if let valueNote = valueNote {
            self.valueNote.value = valueNote
        }
        if let activityNote = activityNote {
            self.activityNote.value = activityNote
        }

    }

    func notificationManagerUpdate() {
        if !notificationManager.authorized.value {
            return
        }

        notificationManager.cancel()

        for day in schedule.days {
            for note in day.notes {
                if
                    case .pending = note.status,
                    let messageManager = messageManagers[note.type],
                    let message = messageManager.find(messageKey: note.messageKey),
                    let triggerOffset = triggerOffsets[note.type]
                {
                    var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: day.date)
                    triggerComponents.hour = trigger.value.hour
                    triggerComponents.minute = trigger.value.minute
                    let date = Calendar.current.date(from: triggerComponents)!.addingTimeInterval(triggerOffset)
                    notificationManager.request(date: date, uuid: note.uuid, type: note.type, message: message)
                }
            }
        }
    }

    func notificationManagerAuthorizationChanged() {
        notificationManagerUpdate()
    }

    func setScheduleDays(days: [Schedule.Day]) {
        schedule = Schedule(days: days)
        showCurrentNotifications()
        dirty = true
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

    func nextNotes(status: Note.Status, date: Date) -> [Note] {
        var notes: [Note] = []
        for (type, messageManager) in messageManagers {
            notes.append(Note(uuid: UUID().uuidString, type: type, messageKey: messageManager.next(), status: status, date: date))
        }
        return notes
    }

    // append days up to the horizon (keep all notes from the past)
    func reschedule() {
        var days: [Schedule.Day] = []
        for day in schedule.days {
            var retainNotes: [Note] = []
            for note in day.notes {
                if !note.isPending {
                    retainNotes.append(note)
                }
            }
            if retainNotes.isEmpty {
                break;
            }
            days.append(Schedule.Day(date: day.date, notes: retainNotes))
        }
        let now = Date()
        var date = Time.previous(date: now, at: trigger.value)
        for _ in 0 ..< horizon {
            var notes = nextNotes(status: date < now ? .expired : .pending, date: date)
            if let lastDay = days.last {
                if lastDay.date == date {
                    notes = lastDay.notes + notes
                    days.removeLast()
                }
            }
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

        var days: [Schedule.Day] = Array<Schedule.Day>(schedule.days)
        let calendar = Calendar.current
        let now = Date()
        let startDate = Time.previous(date: now, at: trigger.value)
        let endDate = calendar.date(byAdding: .day, value: horizon, to: startDate)!

        // append days up to the horizon
        let nextDate = Time.next(date: lastDay.date, at: trigger.value)
        var date = nextDate > startDate ? nextDate : startDate
        while date < endDate {
            let notes = nextNotes(status: date < now ? .expired : .pending, date: date)
            days.append(Schedule.Day(date: date, notes: notes))
            date = Time.next(date: date)
        }

        setScheduleDays(days: days)
    }

    func message(forNote note: Note?) -> Message? {
        guard let note = note else {
            return nil
        }
        if note.type == "Value" {
            return valueMessageManager.find(messageKey: note.messageKey)
        }
        if note.type == "Activity" {
            return activityMessageManager.find(messageKey: note.messageKey)
        }
        return nil
    }

    func orderedValuesChanged() {
        valueMessageManager.group = orderedValues.value[0]
        reschedule()
        dirty = true
    }

    func triggerChanged() {
        reschedule()
        dirty = true
    }

    func refresh() {
        extend()

        if healthKitManager.authorized.value {
            queryDailyStepCounts()
            queryHealthKitPersonalInformation()
        }
    }

    func authorizeHealthKit() {
        didAuthorizeHealthKit = true

        do {
            try healthKitManager.authorizeHealthKit { (authorized,  error) -> Void in
                if authorized {
                    DispatchQueue.main.async {
                        self.healthKitAuthorized()
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
        let _ = healthKitManager.queryDailyStepCounts(week: Time.lastWeek(), handler: dailyStepCounts)
    }

    func queryHealthKitPersonalInformation() {
        if let biologicalSex = try? healthKitManager.biologicalSex() {
            let gender: String?
            switch biologicalSex {
            case .male:
                gender = "Male"
            case .female:
                gender = "Female"
            case .other:
                gender = "Other"
            default:
                gender = nil
            }
            if let gender = gender {
                if personalInformation.value.gender == nil {
                    personalInformation.value = personalInformation.value.bySetting(gender: gender)
                }
            }
        }
        if let dateOfBirth = try? healthKitManager.dateOfBirth() {
            let dateComponents = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())
            let age = dateComponents.year
            if personalInformation.value.age == nil {
                personalInformation.value = personalInformation.value.bySetting(age: age)
            }
        }
        healthKitManager.queryMostRecentSamples()
    }

    func healthKitAuthorized() {
        queryDailyStepCounts()
        queryHealthKitPersonalInformation()
    }

    func dailyStepCounts(startDate: Date, stepCounts: [Int?]) {
        dailyStepCounts.value = DailyStepCounts(startDate: startDate, stepCounts: stepCounts)
    }

}
