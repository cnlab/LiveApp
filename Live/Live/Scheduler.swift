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
    let triggers: [DateComponents]
    let triggerOffsets: [String: TimeInterval]
    let horizon: Int

    init(messageManagers: [MessageManager], now: Date, triggers: [DateComponents], triggerOffsets: [String: TimeInterval], horizon: Int) {
        self.messageManagers = messageManagers
        self.now = now
        self.triggers = triggers
        self.triggerOffsets = triggerOffsets
        self.horizon = horizon
    }

    func nextNotes(date: Date) -> [Note] {
        var notes: [Note] = []
        for trigger in LiveManager.shared.triggers.value {
            for messageManager in messageManagers {
                notes.append(Note(uuid: UUID().uuidString, trigger: trigger, type: messageManager.type, messageKey: messageManager.next(), status: .pending, deleted: false))
            }
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
        guard let firstTrigger = LiveManager.shared.triggers.value.first else {
            return previousDays
        }
        var days = previousDays
        let calendar = Calendar.current
        let nextDate: Date
        if let lastDay = previousDays.last {
            let lastDate = dateForTrigger(day: lastDay, trigger: firstTrigger)
            nextDate = calendar.date(byAdding: .day, value: 1, to: lastDate)!
        } else {
            nextDate = Time.previous(date: now, at: firstTrigger)
        }
        let startDate = Time.previous(date: now, at: firstTrigger)
        let currentDate = Time.current(date: now, at: firstTrigger)
        let endDate = calendar.date(byAdding: .day, value: horizon, to: currentDate)!
        var date = nextDate > startDate ? nextDate : startDate
        while date <= endDate {
            let notes = nextNotes(date: date)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let moment = Moment(year: components.year!, month: components.month!, day: components.day!)
            days.append(Schedule.Day(moment: moment, notes: notes))
            date = Time.next(date: date)
        }
        return days
    }

    func dateForTrigger(day: Schedule.Day, trigger: DateComponents) -> Date {
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
        let now = Date()
        var lastOldNoteByType: [String: Note] = [:]
        for day in days {
            for note in day.notes {
                if lastOldNoteByType[note.type] == nil {
                    lastOldNoteByType[note.type] = note
                }
                switch note.status {
                case .expired, .closed:
                    continue
                case .current, .pending:
                    break
                }
                
                let date = dateForTrigger(day: day, trigger: note.trigger)
                if date < now {
                    if let last = lastOldNoteByType[note.type] {
                        last.status = .expired
                    }
                    lastOldNoteByType[note.type] = note
                }
            }
        }
        for (_, note) in lastOldNoteByType {
            note.status = .current
        }
    }

    var failures: Int = 0

    func assertFail() {
        failures += 1
    }

    func assertNoteStatus(days: [Schedule.Day]) {
        var currentNotes: [String: Note] = [:]
        for day in days {
            for note in day.notes {
                if note.status == .current {
                    if currentNotes[note.type] != nil {
                        assertFail()
                        NSLog("multiple current notes of type \(note.type)")
                    }
                    currentNotes[note.type] = note
                }
            }
        }
        if currentNotes.count != 2 {
            assertFail()
            NSLog("incorrect count of current note types")
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
