//
//  SurveyManager.swift
//  Live
//
//  Created by Denis Bohm on 1/3/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class SurveyManager {

    enum SerializationError: Error {
        case missing(String)
        case invalid(String)
    }

    struct Result {

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

        static func json(string: String) -> String {
            return string
        }

        static func jsonString(json: [String: Any], key: String) throws -> String {
            guard let string = json[key] as? String else {
                throw SerializationError.missing(key)
            }
            return string
        }

        static func json(dictionary: [String: Any]) -> [String: Any] {
            return dictionary
        }

        static func jsonStringAnyDictionary(json: [String: Any], key: String) throws -> [String: Any] {
            guard let dictionary = json[key] as? [String: Any] else {
                throw SerializationError.missing(key)
            }
            return dictionary
        }

        static func json(date: Date) -> String {
            return dateFormatter.string(from: date)
        }

        static func jsonDate(json: [String: Any], key: String) throws -> Date {
            guard let string = json[key] as? String else {
                throw SerializationError.missing(key)
            }
            guard let date = dateFormatter.date(from: string) else {
                throw SerializationError.invalid(string)
            }
            return date
        }

        init(json: [String: Any]) throws {
            let scheduledIdentifier = try Result.jsonString(json: json, key: "scheduledIdentifier")
            let scheduledDate = try Result.jsonDate(json: json, key: "scheduledDate")
            let submitDate = try Result.jsonDate(json: json, key: "submitDate")
            let answers = try Result.jsonStringAnyDictionary(json: json, key: "answers")

            self.scheduledIdentifier = scheduledIdentifier
            self.scheduledDate = scheduledDate
            self.submitDate = submitDate
            self.answers = answers
        }

        func json() -> [String: Any] {
            return [
                "scheduledIdentifier": Result.json(string: scheduledIdentifier),
                "scheduledDate": Result.json(date: scheduledDate),
                "submitDate": Result.json(date: submitDate),
                "answers": Result.json(dictionary: answers),
            ]
        }

    }

    static func newDateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }

    static let scheduledInterval: TimeInterval = 14 * 24 * 60 * 60
    static let dateFormatter = newDateFormatter()

    var observable = Observable<Date?>(value: nil)

    var scheduledIdentifier: String = "S1"
    var scheduledDate: Date
    var scheduledDue: Bool = false

    var results: [Result] = []

    var updateTimer = Timer()

    static func loadScheduledDate() -> Date? {
        if let string = UserDefaults.standard.string(forKey: "surveyScheduledDate") {
            if let date = dateFormatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    static func storeScheduledDate(date: Date) {
        let string = SurveyManager.dateFormatter.string(from: date)
        UserDefaults.standard.set(string, forKey: "surveyScheduledDate")
    }

    static func loadResults() -> [Result] {
        var results: [Result] = []
        if let data = UserDefaults.standard.data(forKey: "surveyResults") {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let jsonResults = json as? [Any] {
                    for jsonResultMaybe in jsonResults {
                        if let jsonResult = jsonResultMaybe as? [String: Any] {
                            if let result = try? Result(json: jsonResult) {
                                results.append(result)
                            }
                        }
                    }
                }
            }
        }
        return results
    }

    static func storeResults(results: [Result]) {
        var json: [Any] = []
        for result in results {
            json.append(result.json())
        }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
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
