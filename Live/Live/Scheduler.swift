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

    func removePendingNotes(previousDays: [Schedule.Day]) -> [Schedule.Day] {
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

    func triggerIndex(after date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let moment = Moment(year: components.year!, month: components.month!, day: components.day!)
        for index in 0 ..< triggers.count {
            let triggerDate = Time.date(moment: moment, trigger: triggers[index])
            if triggerDate > date {
                return index
            }
        }
        return triggers.count
    }
    
    func nextNotes(date: Date) -> [Note] {
        var notes: [Note] = []
        for trigger in triggers {
            for messageManager in messageManagers {
                notes.append(Note(uuid: UUID().uuidString, trigger: trigger, type: messageManager.type, messageKey: messageManager.next(), status: .pending, deleted: false))
            }
        }
        return notes
    }
    
    func addDaysToHorizon(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        if triggers.isEmpty {
            return previousDays
        }
        
        var days = previousDays
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        let endDate = calendar.date(byAdding: .day, value: 1 + horizon, to: startOfDay)!
        var date: Date
        if let lastDay = previousDays.last, let lastNote = lastDay.notes.last {
            var notes = lastDay.notes
            var index = triggerIndex(after: dateForTrigger(day: lastDay, trigger: lastNote.trigger))
            while index < triggers.count {
                let trigger = triggers[index]
                for messageManager in messageManagers {
                    notes.append(Note(uuid: UUID().uuidString, trigger: trigger, type: messageManager.type, messageKey: messageManager.next(), status: .pending, deleted: false))
                }
                index += 1
            }
            let moment = lastDay.moment
            days[days.count - 1] = Schedule.Day(moment: moment, notes: notes)
            date = Time.next(date: Calendar.current.date(from: DateComponents(year: moment.year, month: moment.month, day: moment.day))!)
        } else {
            date = startOfDay
        }
        while date < endDate {
            var notes: [Note] = []
            for trigger in triggers {
                for messageManager in messageManagers {
                    notes.append(Note(uuid: UUID().uuidString, trigger: trigger, type: messageManager.type, messageKey: messageManager.next(), status: .pending, deleted: false))
                }
            }
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
        var lastOldNoteByType: [String: Note] = [:]
        for day in days {
            for note in day.notes {
                if lastOldNoteByType[note.type] == nil {
                    lastOldNoteByType[note.type] = note
                }
                switch note.status {
                case .expired, .closed:
                    continue
                case .current:
                    note.status = .pending
                case .pending:
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

    func rescheduleDays(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        updateNoteStatus(days: previousDays)
        var days = removePendingNotes(previousDays: previousDays)
        days = extendDays(previousDays: days)
        assertNoteStatus(days: days)
        return days
    }

    func extendDays(previousDays: [Schedule.Day]) -> [Schedule.Day] {
        updateNoteStatus(days: previousDays)
        let days = addDaysToHorizon(previousDays: previousDays)
        updateNoteStatus(days: days)
        assertNoteStatus(days: days)
        return days
    }

}
