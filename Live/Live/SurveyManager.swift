//
//  SurveyManager.swift
//  Live
//
//  Created by Denis Bohm on 1/3/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class SurveyManager {

    struct Result: JSONConvertable {

        let scheduledIdentifier: String
        let scheduledDate: Date
        let submitDate: Date
        let answers: [String: Any]

        init(scheduledIdentifier: String, scheduledDate: Date, submitDate: Date, answers: [String: Any]) {
            self.scheduledIdentifier = scheduledIdentifier
            self.scheduledDate = scheduledDate
            self.submitDate = submitDate
            self.answers = answers
        }

        init(json: [String: Any]) throws {
            let scheduledIdentifier = try JSON.jsonString(json: json, key: "scheduledIdentifier")
            let scheduledDate = try JSON.jsonDate(json: json, key: "scheduledDate")
            let submitDate = try JSON.jsonDate(json: json, key: "submitDate")
            let answers = try JSON.jsonStringAnyDictionary(json: json, key: "answers")

            self.scheduledIdentifier = scheduledIdentifier
            self.scheduledDate = scheduledDate
            self.submitDate = submitDate
            self.answers = answers
        }

        func json() -> [String: Any] {
            return [
                "scheduledIdentifier": JSON.json(string: scheduledIdentifier),
                "scheduledDate": JSON.json(date: scheduledDate),
                "submitDate": JSON.json(date: submitDate),
                "answers": JSON.json(dictionary: answers),
            ]
        }

    }

    static let scheduledInterval: TimeInterval = 14 * 24 * 60 * 60

    var observable = Observable<Date?>(value: nil)

    var scheduledIdentifier: String = "S1"
    var scheduledDate: Date
    var scheduledDue: Bool = false

    var results: [Result] = []

    var updateTimer = Timer()

    static func loadScheduledDate() -> Date? {
        if let string = UserDefaults.standard.string(forKey: "surveyScheduledDate") {
            if let date = JSON.dateFormatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    static func storeScheduledDate(date: Date) {
        let string = JSON.dateFormatter.string(from: date)
        UserDefaults.standard.set(string, forKey: "surveyScheduledDate")
    }

    static func loadResults() -> [Result] {
        if let data = UserDefaults.standard.data(forKey: "surveyResults") {
            if let json = try? JSON.json(data: data) {
                if let results: [Result] = try? JSON.jsonArray(json: json) {
                    return results
                }
            }
        }
        return []
    }

    static func storeResults(results: [Result]) {
        if let data = try? JSON.json(any: JSON.json(array: results)) {
            UserDefaults.standard.set(data, forKey: "surveyResults")
        }
    }
    
    init() {
        if let date = SurveyManager.loadScheduledDate() {
            scheduledDate = date
        } else {
            scheduledDate = Date(timeIntervalSinceNow: SurveyManager.scheduledInterval)
            SurveyManager.storeScheduledDate(date: scheduledDate)
        }
        results = SurveyManager.loadResults()
        SurveyManager.storeResults(results: results)

        let oneHour: TimeInterval = 60 * 60
        updateTimer = Timer.scheduledTimer(timeInterval: oneHour, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        update()
    }

    @objc func update() {
        let now = Date()
        scheduledDue = now >= scheduledDate
        observable.value = now
    }

    func isScheduledDue() -> Bool {
        return scheduledDue
    }

    func isScheduledFirst() -> Bool {
        return results.isEmpty
    }

    func submit(_ answers: [String: Any]) {
        let result = Result(scheduledIdentifier: scheduledIdentifier, scheduledDate: scheduledDate, submitDate: Date(), answers: answers)
        results.append(result)
        SurveyManager.storeResults(results: results)

        scheduledDate = Date(timeIntervalSinceNow: SurveyManager.scheduledInterval)
        SurveyManager.storeScheduledDate(date: scheduledDate)

        update()
    }

}
