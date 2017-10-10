//
//  Scheduler.swift
//  Live
//
//  Created by Denis Bohm on 1/15/17.
//  Copyright © 2017 Firefly Design LLC. All rights reserved.
//

import Foundation

class Scheduler {

    let messageManagers: [MessageManager]
    let now: Date
    let trigger: DateComponents
    let triggerOffsets: [String: TimeInterval]
    let horizon: Int

    init(messageManagers: [MessageManager], now: Date, trigger: DateComponents, triggerOffsets: [String: TimeInterval], horizon: Int) {
        self.messageManagers = messageManagers
        self.now = now
        self.trigger = trigger
        self.triggerOffsets = triggerOffsets
        self.horizon = horizon
    }

    func nextNotes(status: Note.Status, date: Date) -> [Note] {
        var notes: [Note] = []
        for messageManager in messageManagers {
            notes.append(Note(uuid: UUID().uuidString, type: messageManager.type, messageKey: messageManager.next(), status: status, deleted: false))
        }
        return notes
    }

    func removePendingDays(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        var days: [Schedule.Day] = []
        for day in previousDays {
            var retainNotes: [Note] = []
            for note in day.notes {
                if !note.isPending {
                    retainNotes.append(note)
                }
            }
            if retainNotes.isEmpty {
                break;
            }
            days.append(Schedule.Day(moment: day.moment, notes: retainNotes))
        }
        return days
    }

    func addDaysToHorizon(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        var days = previousDays
        let calendar = Calendar.current
        let nextDate: Date
        if let lastDay = previousDays.last {
            let lastDate = dateForTrigger(day: lastDay)
            nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate)!
        } else {
            nextDate = Time.previous(date: now, at: trigger)
        }
        let startDate = Time.previous(date: now, at: trigger)
        let currentDate = Time.current(date: now, at: trigger)
        let endDate = calendar.date(byAdding: .day, value: horizon, to: currentDate)!
        var date = nextDate > startDate ? nextDate : startDate
        while date <= endDate {
            let notes = nextNotes(status: .pending, date: date)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let moment = Moment(year: components.year!, month: components.month!, day: components.day!)
            days.append(Schedule.Day(moment: moment, notes: notes))
            date = Time.next(date: date)
        }
        return days
    }

    func dateForTrigger(day: Schedule.Day) -> Date {
        return Time.date(moment: day.moment, trigger: trigger)
    }

    func isCurrent(day: Schedule.Day) -> Bool {
        for note in day.notes {
            switch note.status {
            case .current:
                return true
            default:
                break
            }
        }
        return false
    }

    func updateNoteStatus(days: [Schedule.Day]) {
        var haveSetCurrentDay = false
        for day in days.reversed() {
            let date = dateForTrigger(day: day)
            if !haveSetCurrentDay && isCurrent(day: day) {
                haveSetCurrentDay = true
                continue
            }

            if date < now {
                // notes for this day are before the trigger
                if !haveSetCurrentDay {
                    haveSetCurrentDay = true
                    for note in day.notes {
                        note.status = .current
                    }
                } else {
                    for note in day.notes {
                        switch note.status {
                        case .expired, .closed:
                            break
                        case .current, .pending:
                            note.status = .expired
                        }
                    }
                }
            }
        }
    }

    var failures: Int = 0

    func assertFail() {
        failures += 1
    }

    func assertNoteStatus(days: [Schedule.Day]) {
        var currentCount = 0
        for day in days {
            if day.notes.count != 2 {
                assertFail()
            }
            let date = dateForTrigger(day: day)
            if date < now {
                for note in day.notes {
                    switch note.status {
                    case .pending:
                        assertFail()
                    case .current:
                        currentCount += 1
                        if currentCount > 2 {
                            assertFail()
                        }
                        break
                    case .expired:
                        break
                    case .closed:
                        break
                    }
                }
            } else {
                for note in day.notes {
                    switch note.status {
                    case .pending:
                        break
                    case .current:
                        // if the trigger time was moved then the current can be in the future -denis
                        currentCount += 1
                        if currentCount > 2 {
                            assertFail()
                        }
                        break
                    default:
                        assertFail()
                    }
                }
            }
        }
        if currentCount != 2 {
            assertFail()
        }
    }

    // keep all notes from the past
    // remove pending days
    // append days up to the horizon
    // update status
    func rescheduleDays(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        var days = removePendingDays(previousDays: previousDays)
        days = extendDays(previousDays: days)
        return days
    }

    // append days up to the horizon
    // update status
    func extendDays(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        let days = addDaysToHorizon(previousDays: previousDays)
        updateNoteStatus(days: days)
        assertNoteStatus(days: days)
        return days
    }

}
