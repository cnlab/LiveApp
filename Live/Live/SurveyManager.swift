//
//  SurveyManager.swift
//  Live
//
//  Created by Denis Bohm on 1/3/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class SurveyManager {

    class Result: JSONConvertable {

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

        required init(json: [String: Any]) throws {
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

    class State: JSONConvertable {

        var results: [Result]

        var scheduledIdentifier: String = "S1"
        var scheduledDate: Date

        init() {
            results = []
            scheduledDate = Date(timeIntervalSinceNow: SurveyManager.scheduledInterval)
        }

        required init(json: [String: Any]) throws {
            let results: [Result] = try JSON.jsonArray(json: json, key: "results")
            let scheduledIdentifier = try JSON.jsonString(json: json, key: "scheduledIdentifier")
            let scheduledDate = try JSON.jsonDate(json: json, key: "scheduledDate")

            self.results = results
            self.scheduledIdentifier = scheduledIdentifier
            self.scheduledDate = scheduledDate
        }

        func json() -> [String: Any] {
            return [
                "results": JSON.json(array: results),
                "scheduledIdentifier": JSON.json(string: scheduledIdentifier),
                "scheduledDate": JSON.json(date: scheduledDate),
            ]
        }

    }

    static let scheduledInterval: TimeInterval = 14 * 24 * 60 * 60

    var observable = Observable<Date?>(value: nil)
    var scheduledDue: Bool = false
    var updateTimer = Timer()

    var state: State

    init() {
        state = State()

        let oneHour: TimeInterval = 60 * 60
        updateTimer = Timer.scheduledTimer(timeInterval: oneHour, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        update()
    }

    @objc func update() {
        let now = Date()
        scheduledDue = now >= state.scheduledDate
        observable.value = now
    }

    func isScheduledDue() -> Bool {
        return scheduledDue
    }

    func isScheduledFirst() -> Bool {
        return state.results.isEmpty
    }

    func submit(_ answers: [String: Any]) {
        let result = Result(scheduledIdentifier: state.scheduledIdentifier, scheduledDate: state.scheduledDate, submitDate: Date(), answers: answers)
        state.results.append(result)
        state.scheduledDate = Date(timeIntervalSinceNow: SurveyManager.scheduledInterval)
        LiveManager.shared.dirty = true

        update()
    }

    // !!! just for testing and debug
    func changeDueDateToNow() {
        state.scheduledDate = Date()
        update()
    }

}
