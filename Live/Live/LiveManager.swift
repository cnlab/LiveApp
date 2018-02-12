//
//  LiveManager.swift
//  Live
//
//  Created by Denis Bohm on 10/10/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation
import HealthKit

var sharedLiveManager = LiveManager()

protocol LiveManagerDelegate {

    func liveManagerAffirm(_ liveManager: LiveManager, uuid: String, type: String, messageKey: Message.Key, rank: Double)
    
    func liveManagerOpen(_ liveManager: LiveManager, url: URL)
    
}

class LiveManager: NotificationManagerDelegate, TrackerDelegate {

    class var shared: LiveManager { get { return sharedLiveManager } }

    struct DailyStepCounts {
        let startDate: Date
        let stepCounts: [Int?]
    }

    let reminderTimeInterval = 7 * 24 * 60 * 60.0

    var installationDate: Date? = nil
    var installationUUID: String? = nil
    var delegate: LiveManagerDelegate?
    let cloudManager = CloudManager()
    var notificationManager = createNotificationManager()
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
    let valueMessageManager = ValueMessageManager()
    var messageManagers: [MessageManager] {
        get { return [activityMessageManager, valueMessageManager] }
    }
    var personalInformation = Observable<PersonalInformation>(value: PersonalInformation())
    var shareDataWithResearchers = Observable<Bool>(value: false)
    let surveyManager = SurveyManager()
    var dailyStepCounts = Observable<DailyStepCounts?>(value: nil)
    var stepCountByDay: [String: Any] = [:]
    let orderedValues = Observable(value: ValueMessageManager.groups)
    var valueNote = Observable<Note?>(value: nil)
    var activityNote = Observable<Note?>(value: nil)
    var schedule = Schedule(days: [])
    let horizon = 14
    var triggers = Observable<[DateComponents]>(value: [
        DateComponents(hour: 9, minute: 0),
        DateComponents(hour: 12, minute: 0),
        DateComponents(hour: 15, minute: 0),
        DateComponents(hour: 18, minute: 0),
        ])
    var triggerOffsets: [String: TimeInterval] = ["Activity": 0, "Value": 10]
    var actions: [Tracker.Action] = []
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
    var updateTimer = Timer()

    init() {
        Tracker.sharedInstance().delegate = self
        
        orderedValues.subscribe(owner: self, observer: orderedValuesChanged)
        triggers.subscribe(owner: self, observer: triggersChanged)
        personalInformation.subscribe(owner: self, observer: personalInformationChanged)
        shareDataWithResearchers.subscribe(owner: self, observer: shareDataWithResearchersChanged)

        notificationManager.delegate = self
        notificationManager.authorized.subscribe(owner: self, observer: notificationManagerAuthorizationChanged)

        healthKitManager.bodyMass.subscribe(owner: self, observer: bodyMassChanged)
        healthKitManager.height.subscribe(owner: self, observer: heightChanged)
    }
    
    func startUpdating() {
        let updateInterval: TimeInterval = 1 * 60
        updateTimer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func stopUpdating() {
        updateTimer.invalidate()
    }
    
    @objc func update() {
        refresh()
    }
    
    func tracker(_ tracker: Tracker, action: Tracker.Action) {
        actions.append(action)
        dirty = true
    }
    
    // !!! just for testing and debug
    func changeShareReminderDateToNow() {
        guard let installationDate = installationDate else {
            return
        }
        let date = Date().addingTimeInterval(-reminderTimeInterval)
        if date < installationDate {
            self.installationDate = date
        }
    }

    func personalInformationChanged() {
        dirty = true
    }
    
    func shareDataWithResearchersChanged() {
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
            "actions": JSON.json(array: actions),
//            "trigger": LiveManager.json(dateComponents: trigger.value),
            "triggers": JSON.json(dateComponentsArray: triggers.value),
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
            "shareDataWithResearchers": JSON.json(bool: shareDataWithResearchers.value),
            "stepCountByDay": JSON.json(dictionary: stepCountByDay)
        ]
        do {
            let data = try JSON.json(any: json)
            try data.write(to: archivePath, options: Data.WritingOptions.atomic)

            if shareDataWithResearchers.value {
                if let installationUUID = installationUUID {
                    cloudManager.update(type: "Archive", name: installationUUID, fileURL: archivePath, modificationDate: modificationDate)
                }
            }
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
            let actions = try JSON.jsonArray(json: json, key: "actions", fallback: self.actions)
            let triggers: [DateComponents]
            if json["triggers"] != nil {
                triggers = try JSON.jsonDateComponentsArray(json: json, key: "triggers", fallback: self.triggers.value)
            } else {
                let trigger = try LiveManager.jsonDefaultDateComponents(json: json, key: "trigger", fallback: DateComponents(hour: 9, minute: 0))
                triggers = [trigger]
            }
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
            let stepCountByDay: [String: Any] = try JSON.jsonDefaultStringAnyDictionary(json: json, key: "stepCountByDay", fallback: self.stepCountByDay)

            self.installationDate = installationDate
            self.installationUUID = installationUUID
            self.modificationDate = modificationDate
            self.actions = actions
            self.triggers.value = triggers
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
            self.shareDataWithResearchers.value = shareDataWithResearchers
            self.stepCountByDay = stepCountByDay

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

        surveyManager.update()
    }

    func authorizeNotificationManager() {
        didAuthorizeNotificationManager = true

        notificationManager.authorize()
    }

    func delete(uuid: String) {
        var found = false
        for day in schedule.days {
            for note in day.notes {
                if note.uuid == uuid {
                    note.deleted = true
                    found = true
                    break
                }
            }
        }
        if !found {
            NSLog("could not find uuid \(uuid)")
        }
        dirty = true
    }
    
    func affirm(uuid: String, type: String, messageKey: Message.Key, rank: Double) {
        var found = false
        for day in schedule.days {
            for note in day.notes {
                if note.uuid == uuid {
                    note.rating = Note.Rating(date: Date(), rank: rank)
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
        if !schedule.hasPending {
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
                if note.isCurrent {
                    if note.type == "Value" {
                        valueNote = note
                    } else
                    if note.type == "Activity" {
                        activityNote = note
                    }
                }
            }
        }
        if valueNote == nil {
            NSLog("no current value note!")
        }
        if activityNote == nil {
            NSLog("no current activity note!")
        }
//        if let valueNote = valueNote {
            self.valueNote.value = valueNote
//        }
//        if let activityNote = activityNote {
            self.activityNote.value = activityNote
//        }

    }

    func messageManagerFor(type: String) -> MessageManager? {
        for messageManager in messageManagers {
            if messageManager.type == type {
                return messageManager
            }
        }
        return nil
    }

    func notificationManagerUpdate() {
        if !notificationManager.authorized.value {
            return
        }

        notificationManager.cancel()

        let now = Date()
        for day in schedule.days {
            for note in day.notes {
                if
                    (note.isPending || note.isCurrent) && (note.rating == nil),
                    let messageManager = messageManagerFor(type: note.type),
                    let message = messageManager.find(messageKey: note.messageKey),
                    let triggerOffset = triggerOffsets[note.type]
                {
                    let date = Time.date(moment: day.moment, trigger: note.trigger).addingTimeInterval(triggerOffset)
                    if date > now {
                        notificationManager.request(date: date, uuid: note.uuid, type: note.type, message: message)
                    }
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

    func notificationManagerWillPresent(_ notificationManager: NotificationManager) {
        extend()
    }

    func notificationManager(_ notificationManager: NotificationManager, outstanding: [NoteKey]) {
        var uuids = Set<String>()
        for noteKey in outstanding {
            uuids.insert(noteKey.uuid)
        }

        let date = Date()
        for day in schedule.days {
            for note in day.notes {
                let notificationDate = Time.date(moment: day.moment, trigger: note.trigger)
                if notificationDate < date {
                    if case .pending = note.status {
                        if !uuids.contains(note.uuid) {
                            note.status = .closed
                        }
                    }
                }
            }
        }
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

    func resetSchedule() {
        NSLog("reset schedule")
        let scheduler = Scheduler(messageManagers: messageManagers, now: Date(), triggers: triggers.value, triggerOffsets: triggerOffsets, horizon: horizon)
        let days = scheduler.extendDays(previousDays: [])
        setScheduleDays(days: days)
    }

    func reschedule() {
        NSLog("reschedule")
        let scheduler = Scheduler(messageManagers: messageManagers, now: Date(), triggers: triggers.value, triggerOffsets: triggerOffsets, horizon: horizon)
        let days = scheduler.rescheduleDays(previousDays: schedule.days)
        setScheduleDays(days: days)
    }

    func extend() {
        NSLog("extend")
        let scheduler = Scheduler(messageManagers: messageManagers, now: Date(), triggers: triggers.value, triggerOffsets: triggerOffsets, horizon: horizon)
        let days = scheduler.extendDays(previousDays: schedule.days)
        setScheduleDays(days: days)
    }

    func orderedValuesChanged() {
        valueMessageManager.group = orderedValues.value[0]
        reschedule()
        dirty = true
    }

    func triggersChanged() {
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
                        print("\(String(describing: error))")
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
        
        var stepCountDate = startDate
        for stepCount in stepCounts {
            if let stepCount = stepCount {
                var save = false
                let day = Time.utcDayString(date: stepCountDate)
                if let value = stepCountByDay[day] as? Int {
                    if stepCount > value {
                        save = true
                    }
                } else {
                    save = true
                }
                if save {
                    stepCountByDay[day] = stepCount
                    dirty = true
                }
            }
            stepCountDate = Time.next(date: stepCountDate)
        }
    }

}
