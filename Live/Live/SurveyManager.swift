//
//  SurveyManager.swift
//  Live
//
//  Created by Denis Bohm on 1/3/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class SurveyManager {

    struct Result {
        let scheduledIdentifier: String
        let scheduledDate: Date
        let submitDate: Date
        let answers: [String: Any]
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

    var scheduledIdentifier: String = "S1"
    var scheduledDate: Date

    var results: [Result] = []

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

    init() {
        if let date = SurveyManager.loadScheduledDate() {
            scheduledDate = date
        } else {
            scheduledDate = Date(timeIntervalSinceNow: SurveyManager.scheduledInterval)
            SurveyManager.storeScheduledDate(date: scheduledDate)
        }
    }

    func isScheduledDue() -> Bool {
        return Date() >= scheduledDate
    }

    func isScheduledFirst() -> Bool {
        return results.isEmpty
    }

    func submit(_ answers: [String: Any]) {
        let result = Result(scheduledIdentifier: scheduledIdentifier, scheduledDate: scheduledDate, submitDate: Date(), answers: answers)
        results.append(result)

        scheduledDate = Date(timeIntervalSinceNow: SurveyManager.scheduledInterval)
        SurveyManager.storeScheduledDate(date: scheduledDate)
    }

}
