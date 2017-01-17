//
//  Time.swift
//  Live
//
//  Created by Denis Bohm on 10/10/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Time {

    static func date(moment: Moment, trigger: DateComponents) -> Date {
        var components = trigger
        components.year = moment.year
        components.month = moment.month
        components.day = moment.day
        return Calendar.current.date(from: components)!
    }

    static func current(date: Date, at: DateComponents) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: at.hour ?? 0, minute: at.minute ?? 0, second: at.second ?? 0, of: date)!
    }

    static func previous(date: Date, at: DateComponents) -> Date {
        let calendar = Calendar.current
        let atDate = calendar.date(bySettingHour: at.hour ?? 0, minute: at.minute ?? 0, second: at.second ?? 0, of: date)!
        if atDate < date {
            return atDate
        }
        return calendar.date(byAdding: .day, value: -1, to: atDate)!
    }

    static func next(date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: date)!
    }

    static func countOfDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let startOfStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: start)!
        let startOfEnd = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: end)!
        let duration = startOfEnd.timeIntervalSinceReferenceDate - startOfStart.timeIntervalSinceReferenceDate
        let countOfDays = Int(round(duration / (7.0 * 24.0 * 60.0 * 60.0)))
        return countOfDays
    }

    static func lastWeek() -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let endDate = next(date: Date())
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        return (startDate: startDate, endDate: endDate)
    }

}
